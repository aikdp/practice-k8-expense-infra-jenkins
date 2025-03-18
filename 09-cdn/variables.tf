variable "project_name"{
    default = "expense"
}

variable "environment"{
    default = "dev"
}

variable "common_tags"{
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
        Component = "cdn"
    }
}

variable "cdn_tags"{
    default = {
        Component = "cdn"
    }
}

variable "zone_name"{
    default = "telugudevops.online"
}