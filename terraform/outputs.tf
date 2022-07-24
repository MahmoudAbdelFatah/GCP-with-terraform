output "bastion_open_tunnel_command" {
  description = "Command that opens an SSH tunnel to the Bastion instance."
  value       = "${module.bastion.ssh} -f tail -f /dev/null"
}
