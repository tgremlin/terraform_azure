terraform {
    backend "remote" {
        organization = "tgremlin"
        workspaces {
            name = "terraform_azure"
        }
    }
}