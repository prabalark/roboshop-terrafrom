env              = "prod"
bastion_cidr     = ["172.31.36.132/32"]    # terraform pri-ip
monitor_cidr     = ["172.31.93.225/32"]     # PROMETHEUS pri ip
default_vpc_id   = "vpc-0295140958ce29ed8"  # check in  default vpc
default_vpc_cidr = "172.31.0.0/16"          # check in  default vpc
default_vpc_rtid = "rtb-0358f1519d5a94f36"  # check in  default rout table
kms_arn          = "arn:aws:kms:us-east-1:762233751080:key/6f8c51d4-28a6-4003-a9da-4c25b067e30b"

domain_name      = "devops72bat.online"  # in router53 Hosted zone name
domain_id        = "Z003959020JMJ3CJ14E1Z" # in router53 Hosted zone ID

vpc = {
  main = {
    cidr_block = "10.100.0.0/16"
    subnets = {
      public = {
        name = "public"
        cidr_block = ["10.100.0.0/24","10.100.1.0/24"]
        azs = ["us-east-1a","us-east-1b"]
      }
      web = {            #frontend
        name = "web"
        cidr_block = ["10.100.2.0/24","10.100.3.0/24"]
        azs = ["us-east-1a","us-east-1b"]
      }
      app = {         # all application server
        name = "app"
        cidr_block = ["10.100.4.0/24","10.100.5.0/24"]
        azs = ["us-east-1a","us-east-1b"]
      }
      db = {           # database
        name = "db"
        cidr_block = ["10.100.6.0/24","10.100.7.0/24"]
        azs = ["us-east-1a","us-east-1b"]
      }
    }
  }
}

app = {
  frontend = {
    name = "frontend"
    instance_type     = "t3.small"
    subnet_name       = "web"
    allow_app_cidr    = "public"
    desired_capacity  = 1
    max_size          = 10
    min_size          = 1
    app_port          = 80

    lb_type           = "public"
    listener_priority = 1  # web-server priority num will different

    dns_name          = "prod-ww"
    parameters        = [] #empty not conencting to any db
  }
  catalogue ={
    name              = "catalogue"
    instance_type     = "t3.small"
    subnet_name       = "app"
    allow_app_cidr    = "app"
    desired_capacity  = 1
    max_size          = 10
    min_size          = 1
    app_port          = 8080

    lb_type           = "private"
    listener_priority = 1  # app-server priority num will different
    parameters        = ["docdb"] # connecting to db
  }
  user = {
    name              = "user"
    instance_type     = "t3.small"
    subnet_name       = "app"
    allow_app_cidr    = "app"
    desired_capacity  = 1
    max_size          = 10
    min_size          = 1
    app_port          = 8080
    listener_priority = 2
    lb_type           = "private"
    parameters        = ["docdb"]
  }
  cart = {
    name              = "cart"
    instance_type     = "t3.small"
    subnet_name       = "app"
    allow_app_cidr    = "app"
    desired_capacity  = 1
    max_size          = 10
    min_size          = 1
    app_port          = 8080
    listener_priority = 3
    lb_type           = "private"
    parameters        = []
  }
  shipping = {
    name              = "shipping"
    instance_type     = "t3.small"
    subnet_name       = "app"
    allow_app_cidr    = "app"
    desired_capacity  = 1
    max_size          = 10
    min_size          = 1
    app_port          = 8080
    listener_priority = 4
    lb_type           = "private"
    parameters        = ["rds"]
  }
  payment = {
    name              = "payment"
    instance_type     = "t3.small"
    subnet_name       = "app"
    allow_app_cidr    = "app"
    desired_capacity  = 1
    max_size          = 10
    min_size          = 1
    app_port          = 8080
    listener_priority = 5
    lb_type           = "private"
    parameters        = []
  }
}

docdb = {
  main = {
    subnet_name    = "db"
    allow_db_cidr  = "app"
    engine_version = "4.0.0"
    instance_count = 1
    instance_class = "db.t3.medium"
  }
}

rds = {
  main = {
    subnet_name    = "db"
    allow_db_cidr  = "app"
    engine_version = "5.7.mysql_aurora.2.11.2"
    instance_count = 1
    instance_class = "db.t3.small"
  }
}

elasticache = {
  main = {
    subnet_name             = "db"
    allow_db_cidr           = "app"
    engine_version          = "6.x"
    replicas_per_node_group = 1
    num_node_groups         = 1
    node_type               = "cache.t3.micro"
  }
}

rabbitmq = {
  main = {
    subnet_name   = "db"
    allow_db_cidr = "app"
    instance_type = "t3.small"
  }
}

alb = {
  public = {
    name           = "public"
    subnet_name    = "public" # this is for frontend load-bal
    allow_alb_cidr = null
    #this given in module-alb we get internet from outside ["0.0.0.0/0"]
    internal       = false
  }
  private = {
    name           = "private"
    subnet_name    = "app" # this is for app-server load-bal
    allow_alb_cidr = "web"
    internal       = true
  }
}





