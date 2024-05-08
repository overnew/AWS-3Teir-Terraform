resource "aws_elasticache_cluster" "elastic_cache" {
  cluster_id           = "cluster-example"
  engine               = "memcached"
  node_type            = "cache.m4.large"
  #node_type            = "cache.t4g.medium"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.6"
  port                 = 11211

  az_mode = "cross-az" #default
  #availability_zone = []
  subnet_group_name = "tf-test-cache-subnet"
  security_group_ids = [aws_security_group.elastic_cache.id]
  depends_on = [ aws_elasticache_subnet_group.test, aws_security_group.elastic_cache]
}

resource "aws_elasticache_subnet_group" "test" {
  name       = "tf-test-cache-subnet"
  subnet_ids = var.public_subnet_ids
}

# Security Group for redis elasticache
resource "aws_security_group" "elastic_cache" {
  name        = "tf-test-cache-sg-group"
  description = "ElasticCache Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {  
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}