/**
 * Fancybox 5 Initialization for Daf-HaYomi
 * Includes custom "Don't show again" checkbox injection for post popups
 * Last updated: December 2025
 */

// Initialize Fancybox when DOM is ready
function initFancybox() {
    if (typeof Fancybox === 'undefined') {
        console.error('Fancybox library not loaded');
        return;
    }

    // Bind Fancybox only to image galleries (data-fancybox="gallery")
    Fancybox.bind('[data-fancybox="gallery"]', {
        // Hebrew translations
        l10n: {
            CLOSE: 'סגירה',
            NEXT: 'הבא',
            PREV: 'הקודם',
            ERROR: 'שגיאה בטעינת התמונה'
        },
        Toolbar: {
            display: {
                left: [],
                middle: [],
                right: getToolbarRightItems()
            },
            items: {
                customDownload: {
                    tpl: '<button class="f-button" title="הורדה"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v12"></path><path d="M7 10l5 5 5-5"></path><path d="M5 19h14"></path></svg></button>',
                    click: function (event) {
                        const instance = Fancybox.getInstance();
                        const slide = instance && instance.getSlide();
                        if (slide && slide.src) {
                            triggerDownload(slide.src);
                        }
                    }
                },
                customShare: {
                    tpl: '<button class="f-button" title="שיתוף"><span style="display:inline-block;width:24px;height:24px;background-color:currentColor;-webkit-mask:url(/images/share.svg) no-repeat center / 24px 24px;mask:url(/images/share.svg) no-repeat center / 24px 24px;"></span></button>',
                    click: function (event) {
                        const instance = Fancybox.getInstance();
                        const slide = instance && instance.getSlide();
                        if (slide && slide.src) {
                            triggerShare(slide.src);
                        }
                    }
                },
                customFullscreen: {
                    tpl: '<button class="f-button" title="מסך מלא"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M8 3H5a2 2 0 0 0-2 2v3"></path><path d="M16 3h3a2 2 0 0 1 2 2v3"></path><path d="M21 16v3a2 2 0 0 1-2 2h-3"></path><path d="M3 16v3a2 2 0 0 0 2 2h3"></path></svg></button>',
                    click: function (event) {
                        const instance = Fancybox.getInstance();
                        const slide = instance && instance.getSlide();
                        const videoEl = slide && slide.type === 'html5video'
                            ? instance.container.querySelector('.fancybox__slide.is-selected video')
                            : null;

                        if (videoEl) {
                            requestVideoFullscreen(videoEl);
                        } else if (instance) {
                            instance.toggleFullscreen();
                        }
                    }
                }
            }
        }
    });
}

/**
 * Detects a plain Android WebView (e.g. this site embedded in a native app),
 * as opposed to regular Chrome/Firefox for Android. Android WebView user
 * agents include a "; wv)" token that regular mobile browsers do not have.
 * @returns {boolean}
 */
function isAndroidWebView() {
    return /Android/.test(navigator.userAgent) && /; wv\)/.test(navigator.userAgent);
}

/**
 * Builds the Fancybox toolbar's right-side button list, omitting the
 * download and fullscreen buttons inside an Android WebView, where they are
 * unreliable (no "download" attribute support, no standard Fullscreen API).
 * @returns {string[]}
 */
function getToolbarRightItems() {
    if (isAndroidWebView()) {
        return ["customShare", "slideshow", "thumbs", "close"];
    }
    return ["customShare", "customDownload", "slideshow", "customFullscreen", "thumbs", "close"];
}

/**
 * Requests native fullscreen on a <video> element, using vendor-prefixed
 * fallbacks for older WebKit and iOS Safari (which only supports the native
 * fullscreen video player via webkitEnterFullscreen, not the standard API).
 * @param {HTMLVideoElement} videoEl
 */
function requestVideoFullscreen(videoEl) {
    if (videoEl.requestFullscreen) {
        videoEl.requestFullscreen();
    } else if (videoEl.webkitRequestFullscreen) {
        videoEl.webkitRequestFullscreen();
    } else if (videoEl.webkitEnterFullscreen) {
        videoEl.webkitEnterFullscreen();
    }
}

/**
 * Triggers a same-origin file download using a temporary anchor with the
 * "download" attribute, forcing a save instead of an inline navigation.
 * Falls back to a native bridge or top-level navigation inside Android
 * WebView, where the "download" attribute is generally not honored.
 * @param {string} url - The same-origin resource URL to download
 */
function triggerDownload(url) {
    const absoluteUrl = new URL(url, window.location.href).href;
    const fileName = absoluteUrl.split('/').pop().split('?')[0];

    if (window.AndroidShareBridge && typeof window.AndroidShareBridge.downloadFile === 'function') {
        window.AndroidShareBridge.downloadFile(absoluteUrl, fileName);
        return;
    }

    if (isAndroidWebView()) {
        // Plain WebView usually ignores the "download" attribute; a top-level
        // navigation gives the host app's DownloadListener (if any) a chance
        // to intercept it via Android's DownloadManager.
        window.open(absoluteUrl, '_blank');
        return;
    }

    const link = document.createElement('a');
    link.href = absoluteUrl;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    link.remove();
}

/**
 * Shares media as an actual file (bytes) via the Web Share API Level 2 when
 * supported (mobile Chrome/Edge, iOS Safari 16+), so apps like WhatsApp show
 * a real inline preview instead of a bare link. Falls back to sharing the
 * URL, then to copying the URL to the clipboard.
 * @param {string} url - The (same-origin) resource URL to share
 */
function triggerShare(url) {
    const absoluteUrl = new URL(url, window.location.href).href;

    if (window.AndroidShareBridge && typeof window.AndroidShareBridge.shareUrl === 'function') {
        window.AndroidShareBridge.shareUrl(absoluteUrl);
        return;
    }

    if (isAndroidWebView()) {
        // navigator.share/canShare are not available in a plain WebView, so
        // skip the file-share attempt entirely and go straight to the fallback.
        shareAsUrl(absoluteUrl);
        return;
    }

    shareAsFile(absoluteUrl).then(function (shared) {
        if (!shared) {
            shareAsUrl(absoluteUrl);
        }
    });
}

/**
 * Attempts to fetch the media and share it as a File via navigator.share.
 * @param {string} absoluteUrl - The absolute, same-origin resource URL
 * @returns {Promise<boolean>} Resolves true if a file share was attempted
 */
function shareAsFile(absoluteUrl) {
    if (!navigator.share || !navigator.canShare) {
        return Promise.resolve(false);
    }

    return fetch(absoluteUrl)
        .then(function (response) {
            if (!response.ok) throw new Error('Fetch failed: ' + response.status);
            return response.blob();
        })
        .then(function (blob) {
            const fileName = absoluteUrl.split('/').pop().split('?')[0];
            const file = new File([blob], fileName, { type: blob.type });

            if (!navigator.canShare({ files: [file] })) {
                return false;
            }

            return navigator.share({ files: [file] }).then(function () {
                return true;
            }).catch(function (err) {
                if (err && err.name === 'AbortError') {
                    // User cancelled - do not fall back to URL share
                    return true;
                }
                console.error('File share failed', err);
                return false;
            });
        })
        .catch(function (err) {
            console.error('Could not prepare file for sharing', err);
            return false;
        });
}

/**
 * Shares a media URL using the native Web Share API when available,
 * falling back to copying the absolute URL to the clipboard.
 * @param {string} absoluteUrl - The absolute resource URL to share
 */
function shareAsUrl(absoluteUrl) {
    if (navigator.share) {
        navigator.share({ url: absoluteUrl }).catch(function (err) {
            // Ignore user-cancelled share prompts
            if (err && err.name !== 'AbortError') {
                console.error('Share failed', err);
            }
        });
        return;
    }

    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(absoluteUrl).then(function () {
            alert('הקישור הועתק ללוח');
        }).catch(function () {
            window.prompt('העתק את הקישור:', absoluteUrl);
        });
    } else {
        window.prompt('העתק את הקישור:', absoluteUrl);
    }
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initFancybox);
} else {
    initFancybox();
}

// ====== Post Popup with "Don't Show Again" Checkbox ======
// Fancybox 5 doesn't support custom toolbar items for iframes, so we manually
// inject a checkbox next to the close button in the parent page context.

/**
 * Shows a post popup with Fancybox and injects a "Don't show again" checkbox
 * @param {number} postId - The post ID
 * @param {number} width - Width in pixels
 * @param {number} height - Height in pixels
 */
function showPostPopupWithCheckbox(postId, width, height) {
    if (typeof Fancybox === 'undefined') {
        console.error('Fancybox library not loaded');
        return;
    }

    Fancybox.show([{
        src: '/PopUp.aspx?id=' + postId,
        type: 'iframe',
        width: width,
        height: height
    }], {
        on: {
            ready: function(instance) {
                fancyboxInjectDontShowCheckbox(instance, postId);
            }
        }
    });
}

/**
 * Fancybox ready handler - injects the "Don't show again" checkbox
 * @param {Object} instance - Fancybox instance
 * @param {number} postId - The post ID
 */
function fancyboxInjectDontShowCheckbox(instance, postId) {
    // Wait for DOM to settle (ensure close button is rendered)
    setTimeout(function() {
        injectFancyboxDontShowCheckbox(instance, postId);
    }, 100);
}

/**
 * Core function: Injects the "Don't show again" checkbox next to the close button
 * Fancybox-specific implementation
 * @param {Object} instance - Fancybox instance
 * @param {number} postId - The post ID
 */
function injectFancyboxDontShowCheckbox(instance, postId) {
    var cookieName = 'post_hide_' + postId;

    // Create checkbox container
    const container = document.createElement('div');
    container.className = 'custom-checkbox-container';
    container.innerHTML = `
        <label style="cursor:pointer; display:flex; align-items:center; margin:0; font-family:Arial,sans-serif; font-size:14px; font-weight:bold;">
            <input type="checkbox" id="checkbox-post-${postId}" style="margin-left:8px;">
            אל תציג שוב
        </label>
    `;

    // Find close button and position checkbox next to it
    const closeButton = instance.container.querySelector('.f-button.is-close-btn');

    if (closeButton && closeButton.parentNode) {
        closeButton.parentNode.appendChild(container);

        const style = window.getComputedStyle(closeButton);
        const btnWidth = closeButton.offsetWidth || 44;
        const btnHeight = closeButton.offsetHeight || 44;

        Object.assign(container.style, {
            position: 'absolute',
            top: style.top !== 'auto' ? style.top : '0',
            zIndex: '99999',
            display: 'flex',
            alignItems: 'center',
            height: btnHeight + 'px',
            color: '#333',
            background: 'rgba(255,255,255,0.9)',
            padding: '0 10px',
            borderRadius: '4px',
            pointerEvents: 'auto',
            boxShadow: '0 1px 3px rgba(0,0,0,0.2)'
        });

        // Position dynamically based on close button location
        if (style.right !== 'auto' && style.right !== '') {
            container.style.right = ((parseFloat(style.right) || 0) + btnWidth) + 'px';
            container.style.left = 'auto';
        } else {
            container.style.left = ((parseFloat(style.left) || 0) + btnWidth) + 'px';
            container.style.right = 'auto';
        }
    } else {
        // Fallback positioning
        instance.container.appendChild(container);
        Object.assign(container.style, {
            position: 'absolute',
            top: '12px',
            right: '50px',
            zIndex: '99999',
            display: 'flex',
            alignItems: 'center',
            pointerEvents: 'auto'
        });
    }

    // Set checkbox state from cookie
    const checkbox = container.querySelector('input');
    if (typeof $ !== 'undefined' && $.cookie && $.cookie(cookieName) === '1') {
        checkbox.checked = true;
    }

    // Handle checkbox change
    checkbox.addEventListener('change', function(e) {
        handleDontShowCheckboxChange(e, postId, cookieName);
    });
}

/**
 * Handles checkbox state change and manages cookies
 * @param {Event} event - Change event
 * @param {number} postId - The post ID
 * @param {string} cookieName - Cookie name
 */
function handleDontShowCheckboxChange(event, postId, cookieName) {
    const isChecked = event.target.checked;

    if (typeof $ !== 'undefined' && $.cookie) {
        if (isChecked) {
            // Set cookie for 180 days
            $.cookie(cookieName, '1', { expires: 180, path: '/' });
        } else {
            // Remove cookie
            $.cookie(cookieName, '', { expires: -1, path: '/' });
        }
    } else {
        console.warn('jQuery Cookie plugin not loaded - checkbox state will not persist');
    }
}
