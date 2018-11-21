package main

import (
	"github.com/hashicorp/terraform/helper/schema"
)

// provider
func Provider() *schema.Provider {
	return &schema.Provider{
		ResourcesMap: map[string]*schema.Resource{
			// resources and funcs
			"example_server": resourceServer(),
		},
	}
}
