/**
 * OLX Theme Manager
 * Handles dark/light mode switching and persists preference in localStorage.
 */
(function () {
    var THEME_KEY = 'olx-theme';
    var DEFAULT   = 'dark';

    function applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem(THEME_KEY, theme);
        updateToggleButtons(theme);
    }

    function updateToggleButtons(theme) {
        document.querySelectorAll('.theme-toggle').forEach(function (btn) {
            btn.innerHTML = theme === 'dark'
                ? '<span>☀️</span> Light'
                : '<span>🌙</span> Dark';
            btn.setAttribute('aria-label', theme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode');
        });
    }

    function getSaved() {
        try { return localStorage.getItem(THEME_KEY) || DEFAULT; }
        catch(e) { return DEFAULT; }
    }

    // Apply on load (anti-FOUC — also set by inline script in <head>)
    var saved = getSaved();
    applyTheme(saved);

    // Expose globally
    window.OLXTheme = {
        toggle: function () {
            var current = document.documentElement.getAttribute('data-theme') || DEFAULT;
            applyTheme(current === 'dark' ? 'light' : 'dark');
        },
        set: function (theme) { applyTheme(theme); },
        get: function () { return document.documentElement.getAttribute('data-theme') || DEFAULT; }
    };
})();
