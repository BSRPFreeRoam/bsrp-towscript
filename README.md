# BSRP FreeRoam - Tow Script

## Description
This script allows players to use tow trucks to tow other vehicles in the BSRP FreeRoam server. The script integrates with the QB-Core framework and uses `progressbar` and `oxlib` for progress bars and notifications.

## Features
- Tow different types of vehicles including cars and trailers
- Distance checks to ensure realistic towing operations
- Progress bars to show towing status
- Notifications for various towing actions and errors

## Installation

1. **Download and Extract**
   - Download the script from the repository.
   - Extract the contents into your `resources` directory.

2. **Add to `server.cfg`**
   - Add the following line to your `server.cfg` to ensure the resource is started:
     ```plaintext
     ensure tow-script
     ```

3. **Dependencies**
   - Ensure you have the following resources installed and started in your `server.cfg`:
     ```plaintext
     ensure qb-core
     ensure progressbar
     ensure oxlib
     ```

## Usage

### Commands
- `/tow`: This command will initiate the towing process for the player.

### Notifications
The script uses `lib.notify` to send notifications to the player. The notifications will inform the player of the status of their towing actions.

### Progress Bars
The script uses `progressbar` to display progress bars during the towing process.

## Configuration
- The script allows configuration of what types of vehicles can be towed. You can modify these settings in the `client/main.lua` file:
  ```lua
  local allowTowingBoats = false
  local allowTowingPlanes = false
  local allowTowingHelicopters = false
  local allowTowingTrains = false
  local allowTowingTrailers = true
