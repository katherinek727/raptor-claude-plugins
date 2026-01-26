#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "mcp"
require "httparty"
require "json"

# Configuration
GITLAB_URL = ENV.fetch("GITLAB_URL", "https://gitlab.com")
GITLAB_TOKEN = ENV.fetch("GITLAB_TOKEN") { raise "GITLAB_TOKEN environment variable required" }

# Repository configuration
REPOS = {
  "cpoms" => {
    project: "raptortech1/raptor/cpoms/cpoms",
    scripts_path: "app/services/scripts",
    branch: "main"
  },
  "staffsafe" => {
    project: "raptortech1/raptor/cpoms/cpoms-scr",
    scripts_path: "app/services/scripts",
    branch: "main"
  }
}.freeze

# GitLab API client
class GitLabClient
  include HTTParty
  base_uri GITLAB_URL

  def initialize
    @headers = {
      "PRIVATE-TOKEN" => GITLAB_TOKEN,
      "Accept" => "application/json"
    }
  end

  def list_files(project:, path:, branch:)
    encoded_project = URI.encode_www_form_component(project)
    response = self.class.get(
      "/api/v4/projects/#{encoded_project}/repository/tree",
      headers: @headers,
      query: { path: path, ref: branch, per_page: 100 }
    )

    raise "GitLab API error: #{response.code} - #{response.body}" unless response.success?

    JSON.parse(response.body)
  end

  def get_file(project:, path:, branch:)
    encoded_project = URI.encode_www_form_component(project)
    encoded_path = URI.encode_www_form_component(path)
    response = self.class.get(
      "/api/v4/projects/#{encoded_project}/repository/files/#{encoded_path}/raw",
      headers: @headers,
      query: { ref: branch }
    )

    raise "GitLab API error: #{response.code} - #{response.body}" unless response.success?

    response.body
  end
end

# Helper to extract description from script source
def extract_description(source)
  # Look for: def self.description followed by a string
  match = source.match(/def self\.description\s*\n?\s*["']([^"']+)["']/m)
  match ? match[1] : nil
end

# Helper to extract options/arguments from script source
def extract_options(source)
  # Look for: def initialize(foo:, bar:, baz:)
  match = source.match(/def initialize\(([^)]*)\)/)
  return [] unless match

  args = match[1]
  args.scan(/(\w+):/).flatten
end

# Tool: List all scripts from a project
class ListScriptsTool < MCP::Tool
  description "List all available scripts from CPOMS or StaffSafe GitLab repository"

  input_schema(
    properties: {
      project: {
        type: "string",
        enum: %w[cpoms staffsafe],
        description: "Which project to list scripts from"
      }
    },
    required: ["project"]
  )

  class << self
    def call(project:, server_context: nil)
      repo_config = REPOS[project]
      raise "Unknown project: #{project}" unless repo_config

      client = GitLabClient.new
      files = client.list_files(
        project: repo_config[:project],
        path: repo_config[:scripts_path],
        branch: repo_config[:branch]
      )

      # Filter to only .rb files (exclude base.rb and directories)
      script_files = files.select { |f| f["type"] == "blob" && f["name"].end_with?(".rb") && f["name"] != "base.rb" }

      scripts = script_files.map do |file|
        # Fetch each file to extract description
        begin
          source = client.get_file(
            project: repo_config[:project],
            path: file["path"],
            branch: repo_config[:branch]
          )

          {
            name: file["name"].sub(/\.rb$/, ""),
            file: file["name"],
            path: file["path"],
            description: extract_description(source),
            options: extract_options(source)
          }
        rescue => e
          {
            name: file["name"].sub(/\.rb$/, ""),
            file: file["name"],
            path: file["path"],
            error: e.message
          }
        end
      end

      MCP::Tool::Response.new([{
        type: "text",
        text: JSON.pretty_generate({
          project: project,
          repository: repo_config[:project],
          count: scripts.length,
          scripts: scripts
        })
      }])
    end
  end
end

# Tool: Get full source code for a specific script
class GetScriptTool < MCP::Tool
  description "Get the full source code and details for a specific script"

  input_schema(
    properties: {
      project: {
        type: "string",
        enum: %w[cpoms staffsafe],
        description: "Which project the script is from"
      },
      name: {
        type: "string",
        description: "Script name (e.g., 'fix_duplicate_students' or 'fix_duplicate_students.rb')"
      }
    },
    required: %w[project name]
  )

  class << self
    def call(project:, name:, server_context: nil)
      repo_config = REPOS[project]
      raise "Unknown project: #{project}" unless repo_config

      # Ensure .rb extension
      filename = name.end_with?(".rb") ? name : "#{name}.rb"
      file_path = "#{repo_config[:scripts_path]}/#{filename}"

      client = GitLabClient.new
      source = client.get_file(
        project: repo_config[:project],
        path: file_path,
        branch: repo_config[:branch]
      )

      MCP::Tool::Response.new([{
        type: "text",
        text: JSON.pretty_generate({
          project: project,
          name: name,
          path: file_path,
          description: extract_description(source),
          options: extract_options(source),
          source: source
        })
      }])
    rescue => e
      MCP::Tool::Response.new([{
        type: "text",
        text: JSON.pretty_generate({
          error: e.message,
          project: project,
          name: name
        })
      }])
    end
  end
end

# Start the MCP server
server = MCP::Server.new(
  name: "gitlab-scripts",
  version: "1.0.0",
  tools: [ListScriptsTool, GetScriptTool]
)

transport = MCP::Server::Transports::StdioTransport.new(server)
transport.open
