package main

import (
	"github.com/hashicorp/terraform/helper/schema"
)

// resource server schema
func resourceServer() *schema.Resource {
	return &schema.Resource{
		Create: resourceServerCreate,
		Read:   resourceServerRead,
		Update: resourceServerUpdate,
		Delete: resourceServerDelete,

		Schema: map[string]*schema.Schema{
			// address is required
			"address": &schema.Schema{
				Type:     schema.TypeString,
				Required: true,
			},
		},
	}
}

// create resource
func resourceServerCreate(data *schema.ResourceData, m interface{}) error {
	address := data.Get("address").(string)
	data.SetId(address)
	return nil
}

// read resource
func resourceServerRead(data *schema.ResourceData, m interface{}) error {
	client := m.(*MyClient) // myclient undefined though

	// Attempt to read from an upstream API
	obj, ok := client.Get(data.Id())

	// If the resource does not exist, inform Terraform. We want to immediately
	// return here to prevent further processing.
	if !ok {
		data.SetId("")
		return nil
	}

	data.Set("address", obj.Address)
	return nil
}

// update resource
func resourceServerUpdate(data *schema.ResourceData, m interface{}) error {
	// Enable partial state mode
	data.Partial(true)

	if data.HasChange("address") {
		// Try updating the address
		if err := updateAddress(data, m); err != nil {
			return err
		}

		data.SetPartial("address")
	}

	// If we were to return here, before disabling partial mode below,
	// then only the "address" field would be saved.

	// We succeeded, disable partial mode. This causes Terraform to save
	// all fields again.
	data.Partial(false)

	return nil
}

// update address helper
func updateAddress(data *schema.ResourceData, m interface{}) error {
	return nil
}

// delete resource
func resourceServerDelete(data *schema.ResourceData, m interface{}) error {
	// d.SetId("") is automatically called assuming delete returns no errors, but it is added here for explicitness.
	data.SetId("")
	return nil
}
