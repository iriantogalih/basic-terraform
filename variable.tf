variable "instance_type" {
 
}

variable "instance_count" {
    type = number
}

variable "enable_public" {
    type = bool
}

variable "environment_name" {

}

//variable "user_name" {
//  type = list(string)
//  default = ["user1", "user2", "user3"]
//  description = "IAM User"
//}

//variable "project_environment" {
//  type = map(string)
//  default = {
//      project = "project alpha"
//      environment = "dev"
//  }  
//}

