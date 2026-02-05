---
owner: Architecture Guild
last-reviewed: 2026-02-05
scope: Azure Functions V4 (.NET 6/7/8/9)
version-range: net6.0, net7.0, net8.0, net9.0
detection-markers:
  - "host.json"
  - "[FunctionName]" (in-process attribute)
  - "FunctionsStartup" (in-process startup)
  - "No shared ContainerConfiguration.cs"
---

# Application Profile: Azure Function App (Legacy - .NET 6-9)

Raptor-specific patterns for **existing** Azure Function applications on .NET 6-9. Extends dotnet.md with concrete implementation standards.

> **For new applications on .NET 10+**, use the [Function App v10 Profile](dotnet-function-v10-profile.md) instead.

## Characteristics

- Event-driven, serverless compute
- Triggered by HTTP, Service Bus, Timer, Blob, or other Azure events
- Stateless processing with external state storage
- Deployed as containerized applications to Kubernetes (not consumption plan)

---

## Project Structure

### Single Function App

```
{service-name}/
├── src/
│   └── Raptor.{Service}.Functions/
│       ├── Infrastructure/
│       │   ├── Exceptions/
│       │   ├── Services/
│       │   └── Mappers/
│       ├── Repositories/
│       ├── Models/
│       ├── {TriggerName}Function.cs
│       ├── Startup.cs
│       ├── host.json
│       └── local.settings.json
├── test/
│   └── Raptor.{Service}.Functions.UnitTests/
├── k8s/
└── Dockerfile
```

### Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Function Class | `{TriggerName}Function.cs` | `ProcessOrderFunction.cs` |
| Service | `I{Name}Service` / `{Name}Service` | `IOrderService` |
| Repository | `I{Entity}Repository` / `{Entity}Repository` | `IConfigurationRepository` |
| Processor | `I{Name}Processor` / `{Name}Processor` | `IIncidentProcessor` |

---

## Dependency Injection

### Container: Microsoft DI

Function Apps use **Microsoft DI** (not SimpleInjector like Web APIs).

### In-Process Model (FunctionsStartup)

```csharp
[assembly: FunctionsStartup(typeof(Startup))]

public class Startup : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        var configuration = builder.GetContext().Configuration;

        // Singletons
        builder.Services.AddSingleton(CreateCosmosClient(configuration));

        // Scoped services
        builder.Services.AddScoped<IConfigurationRepository, ConfigurationRepository>();
        builder.Services.AddScoped<IOrderProcessor, OrderProcessor>();

        // MediatR
        builder.Services.AddMediatR(cfg =>
            cfg.RegisterServicesFromAssembly(typeof(Startup).Assembly));
    }
}
```

### Isolated Worker Model (.NET 8+)

```csharp
var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices((context, services) =>
    {
        services.AddScoped<IMyService, MyService>();
    })
    .Build();

host.Run();
```

### Lifetime Guidelines

| Component | Lifetime | Rationale |
|-----------|----------|-----------|
| Cosmos Client | Singleton | Thread-safe, connection pooling |
| Service Bus Client | Singleton | Connection reuse |
| HTTP Client Factory | Singleton | Socket management |
| Repositories | Scoped | Per-invocation data access |
| Processors/Services | Scoped | Per-invocation business logic |
| MediatR Handlers | Transient | Stateless event handling |

---

## Trigger Types

### HTTP Triggers

```csharp
[FunctionName("ProcessOrder")]
public async Task<IActionResult> Run(
    [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "orders/{orderId}")]
    HttpRequest req,
    Guid orderId,
    ILogger log)
{
    log.LogInformation("Processing order {OrderId}", orderId);
    var result = await _orderService.Process(orderId);
    return new OkObjectResult(result);
}
```

### Service Bus Triggers

```csharp
[FunctionName("OrderCreated")]
public async Task Run(
    [ServiceBusTrigger("orders-topic", "order-processor", Connection = "ServiceBusConnection")]
    ServiceBusReceivedMessage message,
    ILogger log)
{
    var order = message.Body.ToObjectFromJson<OrderMessage>();
    await _processor.Process(order);
}
```

### Timer Triggers

```csharp
[FunctionName("DailyCleanup")]
public async Task Run(
    [TimerTrigger("0 0 2 * * *")] TimerInfo timer,  // 2 AM daily
    ILogger log)
{
    // Cleanup logic
}
```

### Durable Functions (Orchestration)

```csharp
[FunctionName("MonitoringOrchestrator")]
public async Task RunOrchestrator(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    var items = await context.CallActivityAsync<List<Item>>("GetItems", null);
    var tasks = items.Select(item => context.CallActivityAsync("ProcessItem", item));
    await Task.WhenAll(tasks);
}
```

**Use Durable Functions when**:
- Processing takes longer than function timeout
- Need fan-out/fan-in patterns
- Require reliable state management across steps

---

## MediatR for Event Handling

```csharp
// Notification
public record ClientCreatedNotification(ClientCreatedEvent Event) : INotification;

// Handler
public class ClientCreatedHandler : INotificationHandler<ClientCreatedNotification>
{
    public async Task Handle(ClientCreatedNotification notification, CancellationToken ct)
    {
        // Handle event
    }
}

// Usage in function
[FunctionName("ClientCreatedConsumer")]
public async Task Run([ServiceBusTrigger(...)] ServiceBusReceivedMessage message)
{
    var @event = JsonSerializer.Deserialize<ClientCreatedEvent>(message.Body);
    await _mediator.Publish(new ClientCreatedNotification(@event));
}
```

---

## Error Handling

### HTTP Trigger Pattern

```csharp
try
{
    var result = await _orderService.Process(order);
    return new OkObjectResult(result);
}
catch (ValidationException ex)
{
    return new BadRequestObjectResult(ex.Message);
}
catch (NotFoundException ex)
{
    return new NotFoundObjectResult(ex.Message);
}
catch (Exception ex)
{
    log.LogError(ex, "Unexpected error");
    return new StatusCodeResult(500);
}
```

### Service Bus Pattern

Service Bus triggers have **built-in retry**:

```csharp
try
{
    await _processor.Process(payload);
    // Message auto-completed on success
}
catch (TransientException ex)
{
    log.LogWarning(ex, "Transient error, will retry");
    throw; // Rethrow triggers retry
}
```

---

## Configuration

### local.settings.json (Development Only)

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet",
    "ServiceBusConnection": "Endpoint=sb://..."
  }
}
```

### host.json

```json
{
  "version": "2.0",
  "logging": {
    "logLevel": {
      "default": "Information",
      "Raptor": "Debug"
    }
  },
  "extensions": {
    "serviceBus": {
      "prefetchCount": 10,
      "messageHandlerOptions": {
        "maxConcurrentCalls": 16
      }
    }
  }
}
```

---

## Deployment

### Kubernetes with KEDA Autoscaling

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: {service}-scaledobject
spec:
  scaleTargetRef:
    name: {service}-functions
  minReplicaCount: 1
  maxReplicaCount: 10
  triggers:
    - type: azure-servicebus
      metadata:
        topicName: my-topic
        subscriptionName: my-subscription
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Do This Instead |
|--------------|-----------------|
| Creating clients per invocation | Use DI with singleton lifetime |
| Large function bodies | Extract logic to services |
| Swallowing exceptions silently | Log and rethrow for retry |
| Not using partition keys | Always query Cosmos with partition key |

---

## Key Differences from Web API

| Aspect | Web API | Function App |
|--------|---------|--------------|
| DI Container | SimpleInjector | Microsoft DI |
| Startup | `Startup.cs` | `FunctionsStartup` or `HostBuilder` |
| Configuration | `appsettings.json` | `local.settings.json` + App Config |
| Triggers | HTTP only | HTTP, Service Bus, Timer, Blob, etc. |
| Error Handling | Global middleware | Per-function + trigger retry |
