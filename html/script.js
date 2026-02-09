// ════════════════════════════════════════════════════════════════════════════════════
// HM BUS JOB - NUI SCRIPT
// ════════════════════════════════════════════════════════════════════════════════════

let playerData = null;
let routes = [];
let selectedRouteId = null;
let theme = {};
let isMenuOpen = false; // Track menu state
let locale = {}; // Locale strings from client

// ════════════════════════════════════════════════════════════════════════════════════
// MESSAGE HANDLER
// ════════════════════════════════════════════════════════════════════════════════════

window.addEventListener('message', (event) => {
    const data = event.data;
    
    console.log('[HM BUS JOB NUI] Message received:', data.action);
    
    switch (data.action) {
        case 'openMenu':
            console.log('[HM BUS JOB NUI] Opening menu with data:', data);
            openMenu(data);
            break;
        case 'closeMenu':
            console.log('[HM BUS JOB NUI] Closing menu');
            closeMenu();
            break;
        case 'updateStats':
            updateStats(data.playerData);
            break;
    }
});

// ════════════════════════════════════════════════════════════════════════════════════
// OPEN MENU
// ════════════════════════════════════════════════════════════════════════════════════

function openMenu(data) {
    try {
        console.log('[HM BUS JOB NUI] openMenu() called');
        
        playerData = data.playerData;
        routes = data.routes;
        selectedRouteId = data.selectedRoute || null;
        theme = data.theme || {};
        locale = data.locale || {}; // Get locale strings
        
        console.log('[HM BUS JOB NUI] Player data:', playerData);
        console.log('[HM BUS JOB NUI] Routes count:', routes ? routes.length : 0);
        console.log('[HM BUS JOB NUI] Locale strings:', locale);
        
        // Apply theme colors if provided
        if (theme.primary) {
            document.documentElement.style.setProperty('--themeColor', theme.primary);
        }
        if (theme.accent) {
            document.documentElement.style.setProperty('--accentColor', theme.accent);
        }
        if (theme.success) {
            document.documentElement.style.setProperty('--successColor', theme.success);
        }
        if (theme.error) {
            document.documentElement.style.setProperty('--errorColor', theme.error);
        }
        if (theme.locked) {
            document.documentElement.style.setProperty('--lockedColor', theme.locked);
        }
        if (theme.salary) {
            document.documentElement.style.setProperty('--salaryColor', theme.salary);
        }
        
        console.log('[HM BUS JOB NUI] Theme colors applied');
        
        // Update player info
        console.log('[HM BUS JOB NUI] Calling updatePlayerInfo()...');
        updatePlayerInfo();
        console.log('[HM BUS JOB NUI] Player info updated');
        
        // Render routes
        console.log('[HM BUS JOB NUI] Calling renderRoutes()...');
        renderRoutes();
        console.log('[HM BUS JOB NUI] Routes rendered');
        
        // Show menu
        const menuElement = document.querySelector('.busMenu');
        if (!menuElement) {
            console.error('[HM BUS JOB NUI] ❌ ERROR: .busMenu element not found in DOM!');
            console.error('[HM BUS JOB NUI] Available classes:', document.body.className);
            console.error('[HM BUS JOB NUI] Body children:', document.body.children);
            return;
        }
        
        console.log('[HM BUS JOB NUI] .busMenu element found:', menuElement);
        console.log('[HM BUS JOB NUI] Current display:', menuElement.style.display);
        console.log('[HM BUS JOB NUI] Setting display to flex...');
        
        menuElement.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        isMenuOpen = true; // Mark menu as open
        
        console.log('[HM BUS JOB NUI] ✅ Menu should be visible now!');
        console.log('[HM BUS JOB NUI] New display value:', menuElement.style.display);
        console.log('[HM BUS JOB NUI] isMenuOpen:', isMenuOpen);
    } catch (error) {
        console.error('[HM BUS JOB NUI] ❌ ERROR in openMenu():', error);
        console.error('[HM BUS JOB NUI] Error message:', error.message);
        console.error('[HM BUS JOB NUI] Stack trace:', error.stack);
    }
}

// ════════════════════════════════════════════════════════════════════════════════════
// CLOSE MENU
// ════════════════════════════════════════════════════════════════════════════════════

function closeMenu() {
    console.log('[HM BUS JOB NUI] closeMenu() called - isMenuOpen:', isMenuOpen);
    
    // Don't close if already closed
    if (!isMenuOpen) {
        console.log('[HM BUS JOB NUI] Menu already closed, ignoring closeMenu()');
        return;
    }
    
    console.log('[HM BUS JOB NUI] Closing menu...');
    
    const menuElement = document.querySelector('.busMenu');
    if (menuElement) {
        menuElement.style.display = 'none';
    }
    document.body.style.overflow = 'auto';
    isMenuOpen = false; // Mark menu as closed
    
    console.log('[HM BUS JOB NUI] Menu closed, sending closeMenu to client');
    
    // Send close event to client
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// ════════════════════════════════════════════════════════════════════════════════════
// UPDATE PLAYER INFO
// ════════════════════════════════════════════════════════════════════════════════════

function updatePlayerInfo() {
    try {
        console.log('[HM BUS JOB NUI] updatePlayerInfo() called');
        
        if (!playerData) {
            console.warn('[HM BUS JOB NUI] No playerData available');
            return;
        }
        
        console.log('[HM BUS JOB NUI] Updating stats with:', playerData);
        
        // Update stats
        document.querySelectorAll('.statInline').forEach((stat, index) => {
            const value = stat.querySelector('.value');
            if (index === 0) value.textContent = playerData.level || 1;
            if (index === 1) value.textContent = playerData.experience || 0;
            if (index === 2) value.textContent = playerData.routesDone || 0;
            if (index === 3) value.textContent = '$' + (playerData.totalEarned || 0);
        });
        
        // Update player name
        const nameElement = document.querySelector('.profileInfo .name');
        if (nameElement) {
            nameElement.textContent = playerData.name || locale.unknown_player || 'Unknown';
        }
        
        // Update XP progress bar
        const xpProgress = calculateXPProgress();
        const progressFill = document.querySelector('.progressFill');
        if (progressFill) {
            progressFill.style.width = xpProgress.percentage + '%';
        }
        
        const xpText = document.querySelector('.boxValue');
        if (xpText) {
            xpText.textContent = `${playerData.experience || 0} / ${xpProgress.required} XP`;
        }
        
        console.log('[HM BUS JOB NUI] Player info updated successfully');
    } catch (error) {
        console.error('[HM BUS JOB NUI] ERROR in updatePlayerInfo():', error);
    }
}

// ════════════════════════════════════════════════════════════════════════════════════
// CALCULATE XP PROGRESS
// ════════════════════════════════════════════════════════════════════════════════════

function calculateXPProgress() {
    const level = playerData.level || 1;
    const xp = playerData.experience || 0;
    const baseXP = 500; // From config
    const multiplier = 1.1; // From config
    
    const required = Math.floor(baseXP * Math.pow(multiplier, level - 1));
    const percentage = Math.min(100, (xp / required) * 100);
    
    return { required, percentage };
}

// ════════════════════════════════════════════════════════════════════════════════════
// RENDER ROUTES
// ════════════════════════════════════════════════════════════════════════════════════

function renderRoutes() {
    try {
        console.log('[HM BUS JOB NUI] renderRoutes() called');
        console.log('[HM BUS JOB NUI] Routes to render:', routes ? routes.length : 0);
        
        const container = document.getElementById('routesContainer');
        if (!container) {
            console.error('[HM BUS JOB NUI] ❌ Routes container not found!');
            return;
        }
        
        console.log('[HM BUS JOB NUI] Routes container found:', container);
        
        // Clear existing routes
        container.innerHTML = '';
        console.log('[HM BUS JOB NUI] Container cleared');
        
        // Render each route
        routes.forEach((route, index) => {
            console.log(`[HM BUS JOB NUI] Rendering route ${index}:`, route.name);
            const routeElement = createRouteElement(route, index);
            container.appendChild(routeElement);
        });
        
        console.log('[HM BUS JOB NUI] All routes rendered');
        
        // Add START ROUTE button if a route is selected
        if (selectedRouteId !== null) {
            console.log('[HM BUS JOB NUI] Adding START ROUTE button for route:', selectedRouteId);
            const startButton = document.createElement('button');
            startButton.className = 'button';
            startButton.textContent = locale.start_route_btn || 'START ROUTE';
            startButton.style.marginTop = '20px';
            startButton.addEventListener('click', startRoute);
            container.appendChild(startButton);
        }
        
        console.log('[HM BUS JOB NUI] renderRoutes() completed');
    } catch (error) {
        console.error('[HM BUS JOB NUI] ERROR in renderRoutes():', error);
    }
}

// ════════════════════════════════════════════════════════════════════════════════════
// CREATE ROUTE ELEMENT
// ════════════════════════════════════════════════════════════════════════════════════

function createRouteElement(route, index) {
    const isLocked = playerData.level < route.requiredLevel || 
                     playerData.routesDone < route.requiredRoutesCompleted;
    const isSelected = selectedRouteId === route.id;
    
    const routeGroup = document.createElement('div');
    routeGroup.className = 'routeItemGroup';
    if (isLocked) routeGroup.classList.add('locked');
    if (isSelected) routeGroup.classList.add('selected');
    routeGroup.dataset.route = index;
    
    // Route content (top box + bottom box)
    const routeContent = document.createElement('div');
    routeContent.className = 'routeItemGroupContent';
    
    // Top box - Name & Salary
    const topBox = createTopBox(route);
    routeContent.appendChild(topBox);
    
    // Bottom box - Details or Locked message
    const bottomBox = isLocked ? createLockedBox(route) : createDetailsBox(route);
    routeContent.appendChild(bottomBox);
    
    routeGroup.appendChild(routeContent);
    
    // Action button
    const actionButton = createActionButton(route, isLocked, isSelected);
    routeGroup.appendChild(actionButton);
    
    // Click handlers
    if (!isLocked) {
        // Click on entire route group
        routeGroup.addEventListener('click', (e) => {
            // Don't trigger if clicking action button
            if (!e.target.closest('.routeActionSpan')) {
                selectRoute(route.id);
            }
        });
        
        // Click on action button
        actionButton.addEventListener('click', (e) => {
            e.stopPropagation();
            if (isSelected) {
                startRoute();
            } else {
                selectRoute(route.id);
            }
        });
    }
    
    return routeGroup;
}

// ════════════════════════════════════════════════════════════════════════════════════
// CREATE TOP BOX
// ════════════════════════════════════════════════════════════════════════════════════

function createTopBox(route) {
    const topBox = document.createElement('div');
    topBox.className = 'routeItem noBorder';
    if (selectedRouteId === route.id) topBox.classList.add('selected');
    
    topBox.innerHTML = `
        <div class="routeItemContent">
            <div class="routeItemTop">
                <div class="routeThumbnail noImage"></div>
                <div class="routeNameSalary">
                    <div class="routeName">
                        <div class="label">${locale.route_name || 'Route Name'}</div>
                        <div class="value">${route.name}</div>
                    </div>
                    <div class="routeSalary">
                        <div class="label">${locale.salary || 'Salary'}</div>
                        <div class="value">$${route.salary}</div>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    return topBox;
}

// ════════════════════════════════════════════════════════════════════════════════════
// CREATE DETAILS BOX
// ════════════════════════════════════════════════════════════════════════════════════

function createDetailsBox(route) {
    const detailsBox = document.createElement('div');
    detailsBox.className = 'routeDetailsBox noBorder';
    
    detailsBox.innerHTML = `
        <div class="routeDetails">
            <div class="routeDetail">
                <svg viewBox="0 0 20 20" fill="none">
                    <path d="M10 2L1 18h18L10 2z" fill="#f0c020"/>
                </svg>
                <div>
                    <div class="detailLabel">${locale.stops || 'Stops'}</div>
                    <div class="detailValue">${route.stops.length}</div>
                </div>
            </div>
            <div class="routeDetail">
                <svg viewBox="0 0 24 24" fill="currentColor" style="color: rgba(255,255,255,0.4);">
                    <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
                </svg>
                <div>
                    <div class="detailLabel">${locale.workers || 'Workers'}</div>
                    <div class="detailValue green">2-5*</div>
                </div>
            </div>
            <div class="routeDetail">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: rgba(255,255,255,0.4);">
                    <circle cx="12" cy="12" r="9"/>
                    <path d="M12 6v6l4 2"/>
                </svg>
                <div>
                    <div class="detailLabel">${locale.est_time || 'Est. Time'}</div>
                    <div class="detailValue">${route.estimatedTime}</div>
                </div>
            </div>
            <div class="routeDetail">
                <svg viewBox="0 0 24 24" fill="currentColor" style="color: rgba(255,255,255,0.4);">
                    <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"/>
                    <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z"/>
                </svg>
                <div>
                    <div class="detailLabel">${locale.payment || 'Payment'}</div>
                    <div class="detailValue">$${route.salary}</div>
                </div>
            </div>
        </div>
    `;
    
    return detailsBox;
}

// ════════════════════════════════════════════════════════════════════════════════════
// CREATE LOCKED BOX
// ════════════════════════════════════════════════════════════════════════════════════

function createLockedBox(route) {
    const lockedBox = document.createElement('div');
    lockedBox.className = 'routeDetailsBox noBorder';
    
    let unlockRequirement = '';
    if (playerData.level < route.requiredLevel) {
        // Format: "Level X Required"
        unlockRequirement = (locale.level_required || 'Level %d Required').replace('%d', route.requiredLevel);
    } else if (playerData.routesDone < route.requiredRoutesCompleted) {
        // Format: "X/Y Routes"
        unlockRequirement = (locale.routes_progress || '%d/%d Routes')
            .replace('%d', playerData.routesDone)
            .replace('%d', route.requiredRoutesCompleted);
    }
    
    lockedBox.innerHTML = `
        <div class="routeLocked">
            <div class="lockedLabel">
                <svg viewBox="0 0 24 24" fill="currentColor" style="color: var(--lockedColor);">
                    <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zM12 17c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zM9 8V6c0-1.66 1.34-3 3-3s3 1.34 3 3v2H9z"/>
                </svg>
                ${locale.route_locked || 'Route is Locked'}
            </div>
            <div class="unlockInfo">
                <span>${locale.to_unlock || 'To Unlock'}</span>
                <span class="unlockValue">${unlockRequirement}</span>
                <svg viewBox="0 0 20 20" fill="none">
                    <path d="M10 2L1 18h18L10 2z" fill="#f0c020"/>
                </svg>
            </div>
        </div>
    `;
    
    return lockedBox;
}

// ════════════════════════════════════════════════════════════════════════════════════
// CREATE ACTION BUTTON
// ════════════════════════════════════════════════════════════════════════════════════

function createActionButton(route, isLocked, isSelected) {
    const actionButton = document.createElement('div');
    actionButton.className = 'routeActionSpan';
    
    if (isLocked) {
        actionButton.classList.add('lockedSpan');
        actionButton.innerHTML = `
            <svg viewBox="0 0 24 24" fill="currentColor" style="color: var(--lockedColor);">
                <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zM12 17c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zM9 8V6c0-1.66 1.34-3 3-3s3 1.34 3 3v2H9z"/>
            </svg>
            <span class="actionLabel lockedLabel">${locale.locked || 'Locked'}</span>
        `;
    } else if (isSelected) {
        actionButton.innerHTML = `
            <svg viewBox="0 0 32 32" fill="none" stroke="white" stroke-width="2">
                <circle cx="16" cy="16" r="11"/>
                <circle cx="16" cy="16" r="3.5"/>
                <line x1="16" y1="5" x2="16" y2="12.5"/>
                <line x1="6.5" y1="20.5" x2="13" y2="17.5"/>
                <line x1="25.5" y1="20.5" x2="19" y2="17.5"/>
            </svg>
            <span class="actionLabel selectedLabel">${locale.selected || 'Selected'}</span>
        `;
    } else {
        actionButton.innerHTML = `
            <svg viewBox="0 0 32 32" fill="none" stroke="white" stroke-width="2">
                <circle cx="16" cy="16" r="11"/>
                <circle cx="16" cy="16" r="3.5"/>
                <line x1="16" y1="5" x2="16" y2="12.5"/>
                <line x1="6.5" y1="20.5" x2="13" y2="17.5"/>
                <line x1="25.5" y1="20.5" x2="19" y2="17.5"/>
            </svg>
            <span class="actionLabel">${locale.select || 'Select'}</span>
        `;
    }
    
    return actionButton;
}

// ════════════════════════════════════════════════════════════════════════════════════
// SELECT ROUTE
// ════════════════════════════════════════════════════════════════════════════════════

function selectRoute(routeId) {
    selectedRouteId = routeId;
    
    // Update UI
    renderRoutes();
    
    // Send to client
    fetch(`https://${GetParentResourceName()}/selectRoute`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ routeId: routeId })
    }).then(response => response.json())
      .then(data => {
          if (!data.success && data.message) {
              showNotification(data.message, 'error');
          }
      });
}

// ════════════════════════════════════════════════════════════════════════════════════
// START ROUTE
// ════════════════════════════════════════════════════════════════════════════════════

function startRoute() {
    if (!selectedRouteId) {
        showNotification('Please select a route first!', 'error');
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/startRoute`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ routeId: selectedRouteId })
    }).then(response => response.json())
      .then(data => {
          if (data.success) {
              closeMenu();
          } else if (data.message) {
              showNotification(data.message, 'error');
          }
      });
}

// ════════════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS
// ════════════════════════════════════════════════════════════════════════════════════

function showNotification(message, type = 'info') {
    // Simple notification - you can enhance this
    console.log(`[${type.toUpperCase()}] ${message}`);
}

// ════════════════════════════════════════════════════════════════════════════════════
// UTILITY
// ════════════════════════════════════════════════════════════════════════════════════

function GetParentResourceName() {
    if (window.location.hostname === 'nui-game-internal') {
        // We're in FiveM
        if (window.invokeNative) {
            return window.invokeNative('0xe5e9ebbb', 0); // GET_CURRENT_RESOURCE_NAME
        }
        return 'hm_busjob';
    }
    // We're in browser (for testing)
    return 'hm_busjob';
}

// ════════════════════════════════════════════════════════════════════════════════════
// ESC KEY HANDLER
// ════════════════════════════════════════════════════════════════════════════════════

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && isMenuOpen) {
        console.log('[HM BUS JOB NUI] ESC pressed, closing menu');
        closeMenu();
    }
});

// ════════════════════════════════════════════════════════════════════════════════════
// INITIALIZE
// ════════════════════════════════════════════════════════════════════════════════════

document.addEventListener('DOMContentLoaded', () => {
    // Hide menu by default
    const menu = document.querySelector('.busMenu');
    if (menu) {
        menu.style.display = 'none';
    }
});
