variable "greeting" {
 default = "Hello"
}
variable "name" {
 default = "World"
}
output "message" {
 value = "${var.greeting} ${upper(var.name)}!"
}
variable "list_example" {
 default = ["one", "two", "three"]
}
variable "map_example" {
 default = {
 key1 = "value1"
 key2 = "value2"
 }
}
output "first_element" {
 value = "${element(var.list_example, 0)}"
}
output "map_value" {
 value = "${lookup(var.map_example, "key1")}"
}
variable "text" {
 default = "Terraform"
}
output "base64_encoded" {
 value = "${base64encode(var.text)}"
}
