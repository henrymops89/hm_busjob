<img width="1248" height="832" alt="f1897428-8ed5-43eb-b99f-19f4210d1794" src="https://github.com/user-attachments/assets/472e7d4a-7d3c-4d5c-91a8-c4027c88719b" />[Uploading f1897428-8ed5-43eb-b99f-19f4210d1794.png…]()


A professional bus driver job system for FiveM. Drive routes, earn money, level up, and compete on the leaderboard.

This isn't your typical "spawn a bus and drive around" script. It's a full progression system with routes, stops, experience, and proper tracking. I built it to actually feel like a job, not just another way to grind cash.

## What You Get
<img width="2554" height="1439" alt="Hauptmenü" src="https://github.com/user-attachments/assets/6d6305f3-7beb-410e-9a90-6c8885053519" />

### Core Features

**Route System**
- Multiple configurable routes with different difficulties
- Each route has its own salary, required level, and stops
- Routes unlock as you progress (Level 1 starts easy, Level 5+ unlocks harder routes)
- Automatic return-to-depot system after completing all stops
- Bus despawns automatically when you arrive back at the depot

**Progression System**
- 20 levels of progression (configurable)
- XP-based leveling with configurable requirements
- Earn XP for each stop completed + bonus for finishing the route
- Level requirements for unlocking new routes
- Persistent stats tracking (total routes completed, money earned, etc.)

**Professional UI**
- Clean, modern NUI with smooth animations
- See all your stats: Level, XP, Routes Done, Total Earned
- Visual route selection with locked/unlocked states
- Shows route details: stops, salary, estimated time
- Fully multilingual (English & German included, easy to add more)

**Leaderboard System**
- Track top players by routes completed
- See total earnings and levels
- Accessible via command or NUI
- Updates in real-time

**Admin Tools**
- `/busjob_addxp [amount]` - Give yourself XP for testing
- `/busjob_resetstats` - Reset your stats
- Full debug mode for troubleshooting

### The Details

**Database Integration**
- Automatic MySQL table creation on first start
- Tracks: Level, XP, Routes Done, Total Money Earned
- Per-player stats that persist across sessions
- Efficient queries, won't lag your server

**Multilingual Support**
- Currently includes English and German
- Easy to add more languages (just copy `locales/en.lua` and translate)
- All UI text, notifications, and messages are localized
- Change language in config with one line

**Framework Support**
- QBox (primary)
- QBCore
- ESX
- Auto-detects your framework on start

**Quality of Life**
- Auto-saves progress after each stop
- Can't start a new route while already on one
- Notifications for everything (stop reached, route completed, level up)
- Return-to-depot mechanic prevents route camping
- Configurable spawn location and depot position

## What's NOT Included

Just to be clear:
- **No NPC passengers** - This was tested and removed. The system works without them and honestly, it's cleaner that way.
- **No complex traffic AI** - You drive the route, that's it. No fancy AI stuff.
- **No minigames** - Just drive, complete stops, earn money. Keep it simple.

## Installation

### 1. Download & Extract

Extract `hm_busjob` to your `resources` folder.

### 2. Database Setup

The script creates the table automatically on first start, but if you want to do it manually:

```sql
CREATE TABLE IF NOT EXISTS `hm_busjob_stats` (
  `identifier` varchar(50) NOT NULL,
  `level` int(11) NOT NULL DEFAULT 1,
  `experience` int(11) NOT NULL DEFAULT 0,
  `routesDone` int(11) NOT NULL DEFAULT 0,
  `totalEarned` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 3. Configuration

Open `shared/config.lua` and adjust to your server:

```lua
Config.Locale = 'en'  -- 'en' or 'de'
Config.Debug = false  -- Set to true for troubleshooting

-- Job Location (where the NPC spawns and depot is)
Config.JobLocation = {
    coords = vector4(-1037.04, -2713.83, 13.76, 240.5),
    depot = vector3(-1037.04, -2713.83, 13.76),
    spawnPoint = vector4(-1041.28, -2717.06, 13.76, 240.5)
}

-- Level System
Config.LevelSystem = {
    enabled = true,
    maxLevel = 20,
    baseXP = 500,        -- XP needed for level 2
    xpMultiplier = 1.1   -- Each level needs 10% more XP
}

-- Routes
Config.Routes = {
    -- Add your own routes here
    -- Each route needs: id, name, salary, stops, requiredLevel
}
```

### 4. Add to server.cfg

```
ensure ox_lib
ensure hm_busjob
```

### 5. Start Your Server

That's it. The script will auto-detect your framework and create the database table.

## Usage

### For Players

**Starting a Job:**
1. Go to the bus depot (configurable location)
2. Talk to the NPC or use `/busjob`
3. Select a route (unlocked routes only)
4. Spawn your bus
5. Drive to each stop marker
6. Return to depot after completing all stops
7. Get paid + XP

**Commands:**
- `/busjob` - Open the job menu

### For Admins

**Commands:**
- `/busjob_addxp [amount]` - Add XP to yourself (testing)
- `/busjob_resetstats` - Reset your stats to level 1

**Debug Mode:**
Enable in config with `Config.Debug = true` to see detailed logs in F8 console.

## Adding Custom Routes

Edit `shared/config.lua`:

```lua
Config.Routes = {
    {
        id = 1,
        name = 'Beach Route',
        salary = 500,
        estimatedTime = '12:00',
        requiredLevel = 1,
        requiredRoutesCompleted = 0,
        stops = {
            {
                coords = vector3(x, y, z),
                label = 'Beach Stop 1'
            },
            -- Add more stops...
        }
    },
    -- Add more routes...
}
```

**Route Tips:**
- Start with 8-12 stops per route (sweet spot)
- Lower level routes = shorter, easier
- Higher level routes = longer, more stops, better pay
- Use `requiredLevel` and `requiredRoutesCompleted` to gate content

## Adding New Languages

1. Copy `locales/en.lua` to `locales/yourlanguage.lua`
2. Change the locale code: `Locale.Locales['yourlanguage'] = {`
3. Translate all the strings
4. Set in config: `Config.Locale = 'yourlanguage'`

All 128 strings are in the locale file. Takes about 30 minutes to translate.

## Troubleshooting

### Menu Won't Open
- Check F8 console for errors
- Make sure `ox_lib` is started BEFORE `hm_busjob`
- Try `/restart hm_busjob`

### Level System Not Working
- Check `Config.LevelSystem.enabled = true`
- Enable debug mode to see XP calculations
- Make sure database table exists

### Translations Showing as Keys (e.g., "nui_route_name")
- Restart the resource: `/restart hm_busjob`
- Check that locale files are in `locales/` folder
- Verify `Config.Locale` matches your locale file

### Bus Not Spawning
- Check spawn point isn't blocked
- Make sure you're close to the depot
- Try different spawn coordinates in config

## Performance

Tested on a live server with 100+ players:
- 0.00ms idle (no players in job)
- 0.01-0.02ms per active bus driver
- Database queries are optimized (only saves on important events)
- No unnecessary loops or threads

## Support

For issues, check F8 console with `Config.Debug = true` first. Most problems show up there.

If you're still stuck, make sure:
- ox_lib is updated and working
- Database table was created
- Framework is detected (check server console on start)

## Credits

Built with patience, coffee, and a lot of debugging sessions.

Uses:
- [ox_lib](https://github.com/overextended/ox_lib) for UI and framework
- [oxmysql](https://github.com/overextended/oxmysql) for database

## License

Do whatever you want with it. If you improve it, cool. If you sell it, not cool but I can't stop you.

---

**Version:** 1.2.8  
**Last Updated:** February 2025  
**Framework:** QBox / QBCore / ESX  
**Dependencies:** ox_lib, oxmysql
