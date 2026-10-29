# Development Guardrails

## Networking

- **Never create new networking resources** (VPCs, subnets, internet gateways, NAT gateways, route tables, default VPCs, etc.)
- Always use existing networking infrastructure when testing or deploying
- If a module requires a VPC, adapt the module or test to reference the existing VPC rather than creating new resources
