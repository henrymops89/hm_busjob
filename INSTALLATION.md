# HM Bus Job - Installation Guide

## Quick Start (5 Minutes)

### 1. Dependencies
Make sure these are installed and started BEFORE hm_busjob:
```lua
ensure ox_lib
ensure oxmysql
ensure qb-core      -- or qbx_core or es_extended
ensure ox_target    -- or qb-target (optional)
```

### 2. Extract & Configure
1. Extract `hm_busjob` to your `resources/` folder
2. Open `shared/config.lua`
3. Set your framework (or leave as `'auto'`)

### 3. Add to server.cfg
```lua
ensure hm_busjob
```

### 4. Start Server
The database table will be created automatically!

---

## Database Setup

### Automatic Setup (Recommended)
The script creates the table automatically on first start.

**Verify in console:**
```
[HM BUS JOB] Database initialized
```

If you see this message ✅ - You're done! No SQL import needed.

### Manual Setup (If Auto-Creation Fails)

**Step 1: Check oxmysql**
Make sure oxmysql is started BEFORE hm_busjob:
```lua
ensure oxmysql
ensure hm_busjob  -- Must be AFTER oxmysql!
```

**Step 2: Run SQL Manually**
If auto-creation still fails, import `install.sql`:

1. Open HeidiSQL / phpMyAdmin / MySQL Workbench
2. Select your FiveM database
3. Import the `install.sql` file
4. Restart your server

**Step 3: Verify Table Exists**
```sql
SHOW TABLES LIKE 'hm_busjob_players';
```

Should return: `hm_busjob_players`

---

## Troubleshooting

### Problem: "Routes Done" not updating

**Cause:** Database not saving correctly

**Fix:**
1. Enable debug mode: `Config.Debug = true` in `shared/config.lua`
2. Complete a route
3. Check console for:
   ```
   [HM BUS JOB] Routes Done: 5 → 6
   [HM BUS JOB] Saved data for ABC12345
   ```
4. If you don't see these messages, check your oxmysql connection

**Verify in database:**
```sql
SELECT * FROM hm_busjob_players;
```

### Problem: Player stats not loading

**Cause:** Player not in database

**Fix:**
1. Check console for:
   ```
   [HM BUS JOB] Loaded data for ABC12345 (Level 1, XP 0)
   ```
2. If not, manually insert player:
   ```sql
   INSERT INTO hm_busjob_players (identifier) VALUES ('YOUR_CITIZENID');
   ```
3. Use `/busjob_resetstats` to initialize stats

### Problem: Table doesn't exist

**Cause:** oxmysql not loaded or wrong load order

**Fix:**
1. Check load order in server.cfg:
   ```lua
   ensure oxmysql    # FIRST!
   ensure hm_busjob  # AFTER oxmysql
   ```
2. Restart server
3. If still fails, import `install.sql` manually

### Problem: "Duplicate entry" error

**Cause:** Player already exists in database

**Fix:** This is normal! Ignore this error. The script will load existing data.

---

## Admin Commands

Reset stats if needed:
```lua
/busjob_resetstats              # Reset YOUR stats
/busjob_setlevel 10             # Set YOUR level to 10
/busjob_addxp 1000              # Add 1000 XP to YOU
```

---

## Database Queries

### View all players
```sql
SELECT * FROM hm_busjob_players;
```

### Top 10 by level
```sql
SELECT * FROM hm_busjob_players 
ORDER BY level DESC, experience DESC 
LIMIT 10;
```

### Top 10 by earnings
```sql
SELECT * FROM hm_busjob_players 
ORDER BY total_earned DESC 
LIMIT 10;
```

### Reset specific player
```sql
UPDATE hm_busjob_players 
SET level = 1, experience = 0, routes_done = 0, total_earned = 0 
WHERE identifier = 'ABC12345';
```

### Delete all stats (⚠️ DANGEROUS!)
```sql
TRUNCATE TABLE hm_busjob_players;
```

---

## Support

If you still have issues:

1. **Enable Debug Mode:**
   - `Config.Debug = true` in `shared/config.lua`
   - Restart resource: `/restart hm_busjob`
   - Complete a route
   - Share console output

2. **Check Database:**
   ```sql
   DESCRIBE hm_busjob_players;
   SELECT * FROM hm_busjob_players;
   ```
   - Share results

3. **Contact Support:**
   - Discord: https://discord.gg/mopsscripts
   - GitHub: https://github.com/mopsscripts/hm_busjob/issues

---

Made with ❤️ by MopsScripts
