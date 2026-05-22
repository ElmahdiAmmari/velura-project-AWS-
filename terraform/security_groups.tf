locals {
  anywhere = "0.0.0.0/0"
  vpc_cidr = aws_vpc.main.cidr_block
}

# ── ALB: public HTTP ──────────────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name   = "${var.project_name}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.anywhere]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anywhere]
  }
}

# ── Frontend: accepts from ALB only ──────────────────────────────────────────
resource "aws_security_group" "frontend" {
  name   = "${var.project_name}-frontend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anywhere]
  }
}

# ── Backend services: accept from anything inside the VPC ─────────────────────
resource "aws_security_group" "backend" {
  name   = "${var.project_name}-backend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5001
    to_port     = 5004
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anywhere]
  }
}

# ── Elasticsearch ─────────────────────────────────────────────────────────────
resource "aws_security_group" "elasticsearch" {
  name   = "${var.project_name}-es-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anywhere]
  }
}

# ── Kibana ────────────────────────────────────────────────────────────────────
resource "aws_security_group" "kibana" {
  name   = "${var.project_name}-kibana-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anywhere]
  }
}

# ── RDS MySQL: only backend tasks ────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.anywhere]
  }
}