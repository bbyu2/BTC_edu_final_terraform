# abclog efs
resource "aws_efs_file_system" "abc-efs" {
  creation_token = "abcbit-efs"

  tags = {
    Name = "abcbit-efs"
  }
}

resource "aws_efs_mount_target" "efs-target-abc-a" {
  file_system_id  = aws_efs_file_system.abc-efs.id
  subnet_id       = resource.aws_subnet.pri2-a.id
  security_groups = [resource.aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "efs-target-abc-c" {
  file_system_id  = aws_efs_file_system.abc-efs.id
  subnet_id       = resource.aws_subnet.pri22-c.id
  security_groups = [resource.aws_security_group.efs.id]
}

# prometheus efs
resource "aws_efs_file_system" "pro-efs" {
  creation_token = "prometheus-efs"

  tags = {
    Name = "prometheus-efs"
  }
}

resource "aws_efs_mount_target" "efs-target-pro-a" {
  file_system_id  = aws_efs_file_system.pro-efs.id
  subnet_id       = resource.aws_subnet.pri2-a.id
  security_groups = [resource.aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "efs-target-pro-c" {
  file_system_id  = aws_efs_file_system.pro-efs.id
  subnet_id       = resource.aws_subnet.pri22-c.id
  security_groups = [resource.aws_security_group.efs.id]
}
