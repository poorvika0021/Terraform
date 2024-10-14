resource "local_file" "file1" {
  filename = var.var_1
  content  = var.var_2
}

resource "local_file" "file2" {
  filename = var.var_4
  content  = var.var_3
}

resource "local_file" "file3" {
  filename = var.var_6
  content  = var.var_5
}
