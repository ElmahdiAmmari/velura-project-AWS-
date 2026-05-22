# ── ALB ───────────────────────────────────────────────────────────────────────
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

# ── Target Groups ─────────────────────────────────────────────────────────────
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "auth" {
  name        = "${var.project_name}-auth-tg"
  port        = 5001
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path    = "/auth/health"
    matcher = "200"          # ← strict, not 200-404
  }
}

resource "aws_lb_target_group" "catalog" {
  name        = "${var.project_name}-catalog-tg"
  port        = 5002
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path    = "/catalog/health"
    matcher = "200"          # ← strict, not 200-404
  }
}

resource "aws_lb_target_group" "rental" {
  name        = "${var.project_name}-rental-tg"
  port        = 5003
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path    = "/rental/health"
    matcher = "200"          # ← strict, not 200-404
  }
}

resource "aws_lb_target_group" "admin" {
  name        = "${var.project_name}-admin-tg"
  port        = 5004
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    path    = "/admin/health"
    matcher = "200"          # ← strict, not 200-404
  }
}

# ── Listener: port 80 ─────────────────────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Default → frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ── Listener Rules: backend path routing ──────────────────────────────────────
resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/auth", "/auth/*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }
}

resource "aws_lb_listener_rule" "catalog" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  condition {
    path_pattern { values = ["/catalog", "/catalog/*"] }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalog.arn
  }
}

resource "aws_lb_listener_rule" "rental" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30
  condition {
    path_pattern { values = ["/rental", "/rental/*"] }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rental.arn
  }
}

resource "aws_lb_listener_rule" "admin" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 40
  condition {
    path_pattern { values = ["/admin", "/admin/*"] }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.admin.arn
  }
}