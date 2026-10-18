/**
 * DafYomiModal.js - Custom modal/dialog system for Daf-HaYomi
 * Replaces Fancybox for iframe modals
 * Based on SelectionTranslator.js architecture
 * 
 * Usage:
 *   Declarative: <a href="page.aspx" data-modal data-modal-title="Title" data-modal-width="400" data-modal-height="300">Link</a>
 *   Programmatic: openModal('page.aspx', 'Title', 400, 300)
 *   From iframe: parent.closeModal() or parent.closeAndRefresh()
 * 
 * Dependencies: jQuery 1.10.2+
 * Last updated: December 2025
 */

var DafYomiModal = (function () {
    'use strict';

    var $modal = null;
    var $backdrop = null;
    var $modalContainer = null;
    var $iframe = null;
    var $titleBar = null;
    var isInitialized = false;

    /**
     * Initialize the modal system
     */
    function init() {
        if (isInitialized) return;

        createModalStructure();
        bindEvents();
        initDeclarativeLinks();
        isInitialized = true;
    }

    /**
     * Create modal HTML structure
     */
    function createModalStructure() {
        var modalHtml =
            '<div id="dafYomiBackdrop" class="daf-modal-backdrop" style="display:none;"></div>' +
            '<div id="dafYomiModal" class="daf-modal" style="display:none;">' +
            '  <div class="daf-modal-container">' +
            '    <div class="daf-modal-titlebar">' +
            '      <span class="daf-modal-title"></span>' +
            '      <button class="daf-modal-close" type="button" title="סגור (ESC)">×</button>' +
            '    </div>' +
            '    <div class="daf-modal-content">' +
            '      <iframe class="daf-modal-iframe" frameborder="0" allowtransparency="true"></iframe>' +
            '    </div>' +
            '  </div>' +
            '</div>';

        $('body').append(modalHtml);

        // Cache jQuery objects
        $backdrop = $('#dafYomiBackdrop');
        $modal = $('#dafYomiModal');
        $modalContainer = $modal.find('.daf-modal-container');
        $iframe = $modal.find('.daf-modal-iframe');
        $titleBar = $modal.find('.daf-modal-title');

        // Make modal draggable
        $modalContainer.draggable({
            handle: '.daf-modal-titlebar',
            containment: 'window'
        });
    }

    /**
     * Bind all events
     */
    function bindEvents() {
        // Close button click
        $modal.on('click', '.daf-modal-close', closeModal);

        // ESC key
        $(document).on('keydown', function (e) {
            if (e.keyCode === 27 && $modal.is(':visible')) {
                closeModal();
            }
        });
    }

    /**
     * Initialize declarative links with data-modal attribute
     */
    function initDeclarativeLinks() {
        $(document).on('click', '[data-modal]', function (e) {
            e.preventDefault();

            var $link = $(this);
            var src = $link.attr('href');
            var title = $link.data('modal-title') || $link.data('caption') || '';
            var width = $link.data('modal-width') || $link.data('width') || 400;
            var height = $link.data('modal-height') || $link.data('height') || 300;

            openModal(src, title, width, height);
        });
    }

    /**
     * Open modal with iframe
     * @param {string} src - URL to load in iframe
     * @param {string} title - Modal title
     * @param {number} width - Modal width in pixels
     * @param {number} height - Modal height in pixels
     * @param {Object} options - Optional configuration
     * @param {function} options.onReady - Callback when modal is ready
     * @param {number} options.postId - Post ID (for checkbox injection)
     * @param {boolean} options.injectCheckbox - Auto-inject checkbox (not implemented - use onReady)
     */
    function openModal(src, title, width, height, options) {
        if (!isInitialized) {
            init();
        }

        options = options || {};

        // Clean up title bar from previous modal (remove any checkboxes)
        $titleBar.parent().find('.daf-modal-checkbox-container').remove();

        // Set title
        $titleBar.text(title || '');

        // Set dimensions
        width = parseInt(width) || 400;
        height = parseInt(height) || 300;
        $modalContainer.css({
            width: width + 'px',
            height: height + 'px'
        });

        // Position modal in center
        positionModal();

        // Load iframe
        $iframe.attr('src', src);

        // Show backdrop and modal with fade animation
        $backdrop.fadeIn(200);
        $modal.fadeIn(200, function() {
            // Trigger onReady callback after modal is visible
            if (options.onReady && typeof options.onReady === 'function') {
                // Build modal instance object for callback
                var modalInstance = {
                    modal: $modal,
                    container: $modalContainer,
                    titleBar: $titleBar,
                    iframe: $iframe,
                    backdrop: $backdrop
                };

                // Slight delay to ensure DOM is ready
                setTimeout(function() {
                    options.onReady(modalInstance);
                }, 50);
            }
        });

        // Prevent body scroll
        $('body').css('overflow', 'hidden');
    }

    /**
     * Position modal in center of viewport
     */
    function positionModal() {
        var windowWidth = $(window).width();
        var windowHeight = $(window).height();
        var modalWidth = $modalContainer.outerWidth();
        var modalHeight = $modalContainer.outerHeight();

        var left = Math.max(0, (windowWidth - modalWidth) / 2);
        var top = Math.max(0, (windowHeight - modalHeight) / 2);

        $modalContainer.css({
            left: left + 'px',
            top: top + 'px'
        });
    }

    /**
     * Close modal
     */
    function closeModal() {
        if (!$modal || !$modal.is(':visible')) return;

        // Fade out
        $modal.fadeOut(200, function () {
            // Clear iframe src to stop any loading/scripts
            $iframe.attr('src', 'about:blank');

            // Clean up title bar (remove any checkboxes from previous modal)
            $titleBar.parent().find('.daf-modal-checkbox-container').remove();
        });
        $backdrop.fadeOut(200);

        // Restore body scroll
        $('body').css('overflow', '');
    }

    /**
     * Close modal and refresh parent page
     */
    function closeAndRefresh() {
        closeModal();
        setTimeout(function () {
            window.location.reload();
        }, 100);
    }

    /**
     * Reposition modal on window resize
     */
    $(window).on('resize', function () {
        if ($modal && $modal.is(':visible')) {
            positionModal();
        }
    });

    // Auto-initialize when DOM is ready
    $(document).ready(function () {
        init();
    });

    // Public API
    return {
        init: init,
        open: openModal,
        close: closeModal,
        closeAndRefresh: closeAndRefresh
    };

})();

// Global functions for backwards compatibility and iframe communication
window.openModal = function (src, title, width, height, options) {
    DafYomiModal.open(src, title, width, height, options);
};

window.closeModal = function () {
    DafYomiModal.close();
};

window.closeAndRefresh = function () {
    DafYomiModal.closeAndRefresh();
};
