// Chat Panel - Slide-out Vertical Bar
// Based on test-iframe/index.html design
(function() {
    'use strict';

    var ChatPanel = {
        panel: null,
        closeButton: null,
        iframe: null,
        cookieName: 'chatPanelCollapsed',
        iframeLoaded: false,

        init: function() {
            this.panel = document.getElementById('chatPanelContainer');
            this.closeButton = document.getElementById('btnCloseChatPanel');
            this.iframe = document.getElementById('chatIframe');

            if (!this.panel) {
                return;
            }

            // CRITICAL: Set initial state BEFORE restoring from cookie
            // This prevents flash - panel starts collapsed in HTML
            this.setInitialBodyClass();

            this.attachEventHandlers();
            this.restoreState();
        },

        setInitialBodyClass: function() {
            // Panel starts with 'collapsed' class in HTML
            // Set body class immediately to match
            document.body.classList.add('chat-panel-collapsed');
        },

        attachEventHandlers: function() {
            var self = this;

            // Click on panel when collapsed to expand
            this.panel.addEventListener('click', function(e) {
                if (self.isCollapsed()) {
                    e.preventDefault();
                    e.stopPropagation();
                    self.expand();
                }
            });

            // Close button to collapse
            if (this.closeButton) {
                this.closeButton.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation(); // Prevent panel click from triggering
                    self.collapse();
                });
            }

            // Escape key to collapse
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && !self.isCollapsed()) {
                    self.collapse();
                }
            });
        },

        isCollapsed: function() {
            return this.panel && this.panel.classList.contains('collapsed');
        },

        loadIframe: function() {
            // Only load iframe once, on first expand
            if (!this.iframeLoaded && this.iframe) {
                var srcTemplate = this.iframe.getAttribute('data-src-template');
                if (srcTemplate) {
                    this.iframe.src = srcTemplate;
                    this.iframeLoaded = true;
                }
            }
        },

        expand: function() {
            if (this.panel) {
                this.panel.classList.remove('collapsed');
                document.body.classList.add('chat-panel-expanded');
                document.body.classList.remove('chat-panel-collapsed');

                // Load iframe on first expand
                this.loadIframe();

                this.saveState(false);
            }
        },

        collapse: function() {
            if (this.panel) {
                this.panel.classList.add('collapsed');
                document.body.classList.add('chat-panel-collapsed');
                document.body.classList.remove('chat-panel-expanded');
                this.saveState(true);
            }
        },

        saveState: function(isCollapsed) {
            if (typeof $.cookie === 'function') {
                $.cookie(this.cookieName, isCollapsed ? '1' : '0', { expires: 365, path: '/' });
            }
        },

        restoreState: function() {
            if (typeof $.cookie === 'function') {
                var savedState = $.cookie(this.cookieName);
                if (savedState === '0') {
                    // User had it expanded - expand it (will load iframe)
                    this.expand();
                }
                // If savedState === '1' or undefined, stay collapsed (default)
                // Panel already has 'collapsed' class from HTML, no flash!
            }
        }
    };

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            ChatPanel.init();
        });
    } else {
        ChatPanel.init();
    }

    // Also initialize with jQuery ready (for compatibility)
    if (typeof $ !== 'undefined') {
        $(function() {
            ChatPanel.init();
        });
    }

    // Expose to global scope
    window.ChatPanel = ChatPanel;
})();
