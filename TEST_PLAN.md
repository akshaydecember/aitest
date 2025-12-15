# Test Plan — Failover and Scalability

1) Preconditions
   - Configure AWS credentials with sufficient permissions.
   - Ensure Terraform remote state is configured or run locally for small tests.

2) Smoke deploy (dev)
   - `cd infra/terraform`
   - `terraform init`
   - `terraform workspace select dev || terraform workspace new dev`
   - `terraform apply -var-file=envs/dev.tfvars`
   - Verify outputs: cluster ARNs, VPC IDs, DB endpoint

3) App deployment
   - Build and push Docker image (or use GitHub Actions)
   - Update `app_container_image` variable to point to image
   - Run `terraform apply` again
   - Verify ECS tasks are running in both regions and respond to `/` endpoint

4) Failover test
   - Simulate regional failure by draining ECS tasks in primary region or removing route53 health check success
   - Verify Route53 failover (if configured) switches traffic to secondary region
   - Re-enable primary and verify traffic returns

5) Scaling test
   - Increase load using `hey` or `wrk` against the ALB DNS
   - Observe ECS service scaling (if autoscaling configured)
   - Scale up instance type by adjusting `instance_class` and reapply to test vertical scaling

6) Database replication test
   - Write some test rows to primary DB and observe read replica in secondary (if configured)

7) Zero-downtime deploy test
   - Perform rolling update of ECS task definition (update image tag)
   - Verify minimal/no 5xx errors during rollout
