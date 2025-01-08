# terraform-aviatrix-copilot-init - release notes

## v1.0.4
- Add copilot service account to admin group, in stead of creating a new group.

## v1.0.3
- Increased retry timers, to account for a scenario where the controller is in a upgrading state
- Added flags to allow for dis/enable syslog and netflow configuration

## v1.0.2
- Clean up variable names

## v1.0.1
- Use data source for login (get new CID on every run)
- Cleanup requests for readability
- Correct dependencies
- Make copilot pwd sensitive
- Fix readme typo's
- Add Netflow and Syslog support

## v1.0.0
- Initial release