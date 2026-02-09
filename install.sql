-- ════════════════════════════════════════════════════════════════════════════════════
-- HM BUS JOB - DATABASE INSTALLATION
-- ════════════════════════════════════════════════════════════════════════════════════
-- 
-- This SQL file is OPTIONAL. The script auto-creates the table on first start.
-- Only use this if you want to manually create the table or if auto-creation fails.
--
-- ════════════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `hm_busjob_players` (
    `identifier` VARCHAR(50) PRIMARY KEY,
    `level` INT DEFAULT 1,
    `experience` INT DEFAULT 0,
    `routes_done` INT DEFAULT 0,
    `total_earned` INT DEFAULT 0,
    `last_played` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ════════════════════════════════════════════════════════════════════════════════════
-- OPTIONAL: Sample data for testing
-- ════════════════════════════════════════════════════════════════════════════════════

-- Uncomment the following lines to add test data:
-- INSERT INTO `hm_busjob_players` (`identifier`, `level`, `experience`, `routes_done`, `total_earned`) VALUES
-- ('ABC12345', 5, 1250, 12, 15000),
-- ('DEF67890', 10, 5000, 50, 75000);

-- ════════════════════════════════════════════════════════════════════════════════════
-- RESET STATS (Use with caution!)
-- ════════════════════════════════════════════════════════════════════════════════════

-- Reset a specific player:
-- UPDATE `hm_busjob_players` SET `level` = 1, `experience` = 0, `routes_done` = 0, `total_earned` = 0 WHERE `identifier` = 'YOUR_IDENTIFIER';

-- Reset ALL players:
-- TRUNCATE TABLE `hm_busjob_players`;

-- ════════════════════════════════════════════════════════════════════════════════════
-- VERIFICATION QUERIES
-- ════════════════════════════════════════════════════════════════════════════════════

-- Check if table exists:
-- SHOW TABLES LIKE 'hm_busjob_players';

-- View all player data:
-- SELECT * FROM `hm_busjob_players`;

-- View top 10 players by level:
-- SELECT * FROM `hm_busjob_players` ORDER BY `level` DESC, `experience` DESC LIMIT 10;

-- View top 10 players by earnings:
-- SELECT * FROM `hm_busjob_players` ORDER BY `total_earned` DESC LIMIT 10;

-- View top 10 players by routes completed:
-- SELECT * FROM `hm_busjob_players` ORDER BY `routes_done` DESC LIMIT 10;
