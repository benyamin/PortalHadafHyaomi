/* ================================================================
   gallery-render.js  –  Daf HaYomi public gallery renderer
   Scans the page for <div data-gallery="SLUG"> and renders each
   gallery grid in-place using the public GalleryHandler.ashx.
   Fancybox 5 must be present (already in MasterPage.master).
   ================================================================ */

(function () {
    'use strict';

    var HANDLER = '/GalleryHandler.ashx';

    function init() {
        var containers = document.querySelectorAll('[data-gallery]');
        if (!containers.length) return;
        containers.forEach(function (el) {
            var slug = el.getAttribute('data-gallery');
            if (!slug) return;
            renderGallery(el, slug);
        });
    }

    function renderGallery(container, slug) {
        container.innerHTML = '<span style="color:#999;font-size:12px;">טוען גלריה...</span>';
        fetch(HANDLER + '?action=get&slug=' + encodeURIComponent(slug))
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data.error) { showError(container, data.error); return; }
                buildGrid(container, data);
            })
            .catch(function (e) { showError(container, e.message); });
    }

    function buildGrid(container, data) {
        var cols  = data.cols  || 3;
        var width = data.width || 0;
        var slug  = data.slug;
        var fancyboxGroup = 'gallery-' + slug;

        // data-float comes from the CKEditor placeholder attribute
        var floatVal = (container.getAttribute('data-float') || '').toLowerCase();
        var hasFloat = floatVal === 'left' || floatVal === 'right';

        var grid = document.createElement('div');
        grid.className = 'dfy-gallery dfy-gallery-cols-' + cols;
        // Full-width galleries are capped at 640px (max gallery viewport)
        var effectiveWidth = width > 0 ? width : 640;
        grid.style.maxWidth = effectiveWidth + 'px';
        if (width > 0 || true) { // always cap
            if (hasFloat) {
                grid.style.float = floatVal;
                grid.style[floatVal === 'right' ? 'marginLeft' : 'marginRight'] = '16px';
            } else {
                grid.style.marginRight = 'auto';
                grid.style.marginLeft  = 'auto';
            }
        }

        data.items.forEach(function (item) {
            var div = document.createElement('div');
            div.className = 'dfy-gallery-item';

            if (item.type === 'video') {
                // Fancybox video link — type must be 'html5video' for Fancybox 5
                var a = document.createElement('a');
                a.href = item.url;
                a.setAttribute('data-fancybox', fancyboxGroup);
                a.setAttribute('data-type', 'html5video');
                if (item.thumbUrl) {
                    a.setAttribute('data-poster', item.thumbUrl);
                    // data-thumb drives the filmstrip thumbnail in Fancybox 5
                    a.setAttribute('data-thumb', item.thumbUrl);
                }
                var cap = buildCaption(item);
                if (cap) {
                    a.setAttribute('data-caption-html', cap);
                }

                if (item.thumbUrl) {
                    // FFmpeg extracted a real thumbnail — show it with a play overlay
                    var ph = document.createElement('div');
                    ph.className = 'dfy-video-thumb dfy-video-has-thumb';
                    var ti = document.createElement('img');
                    ti.src = item.thumbUrl;
                    ti.alt = item.title || '';
                    ti.loading = 'lazy';
                    ph.appendChild(ti);
                    var play = document.createElement('div');
                    play.className = 'dfy-video-play';
                    ph.appendChild(play);
                    a.appendChild(ph);
                } else {
                    // No thumbnail — CSS play-button placeholder
                    var ph = document.createElement('div');
                    ph.className = 'dfy-video-thumb';
                    var play = document.createElement('div');
                    play.className = 'dfy-video-play';
                    ph.appendChild(play);
                    a.appendChild(ph);
                }
                div.appendChild(a);
            } else {
                var a = document.createElement('a');
                a.href = item.url;
                a.setAttribute('data-fancybox', fancyboxGroup);
                var cap = buildCaption(item);
                if (cap) {
                    a.setAttribute('data-caption-html', cap);
                }

                var img = document.createElement('img');
                img.src = item.thumbUrl || item.url;
                img.alt = item.title || '';
                img.loading = 'lazy';
                a.appendChild(img);
                div.appendChild(a);
            }

            // Caption below the image
            if (item.title || item.text) {
                var cap = document.createElement('div');
                cap.className = 'dfy-gallery-caption';
                var capHtml = '';
                if (item.title) capHtml += '<strong>' + escHtml(item.title) + '</strong>';
                if (item.text)  capHtml += (capHtml ? '<br>' : '') + item.text;
                cap.innerHTML = capHtml;
                div.appendChild(cap);
            }

            grid.appendChild(div);
        });

        container.innerHTML = '';
        container.appendChild(grid);

        // Re-init Fancybox for newly inserted anchors
        if (window.Fancybox) {
            Fancybox.bind('[data-fancybox="' + fancyboxGroup + '"]', {
                groupAll: false,
                caption: function (fancybox, slide) {
                    var el = slide.triggerEl;
                    var html = el ? el.getAttribute('data-caption-html') : '';
                    if (!html) return '';
                    var div = document.createElement('div');
                    div.innerHTML = html;
                    return div;
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
                                var instance = Fancybox.getInstance();
                                var slide = instance && instance.getSlide();
                                if (slide && slide.src) {
                                    triggerDownload(slide.src);
                                }
                            }
                        },
                        customShare: {
                            tpl: '<button class="f-button" title="שיתוף"><span style="display:inline-block;width:24px;height:24px;background-color:currentColor;-webkit-mask:url(/images/share.svg) no-repeat center / 24px 24px;mask:url(/images/share.svg) no-repeat center / 24px 24px;"></span></button>',
                            click: function (event) {
                                var instance = Fancybox.getInstance();
                                var slide = instance && instance.getSlide();
                                if (slide && slide.src) {
                                    triggerShare(slide.src);
                                }
                            }
                        },
                        customFullscreen: {
                            tpl: '<button class="f-button" title="מסך מלא"><svg viewBox="0 0 24 24" width="24" height="24" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"><path d="M8 3H5a2 2 0 0 0-2 2v3"></path><path d="M16 3h3a2 2 0 0 1 2 2v3"></path><path d="M21 16v3a2 2 0 0 1-2 2h-3"></path><path d="M3 16v3a2 2 0 0 0 2 2h3"></path></svg></button>',
                            click: function (event) {
                                var instance = Fancybox.getInstance();
                                var slide = instance && instance.getSlide();
                                var videoEl = slide && slide.type === 'html5video'
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
                },
                Translations: {
                    he: {
                        CLOSE: 'סגור',
                        NEXT: 'הבא',
                        PREV: 'הקודם',
                        MODAL: 'אתה יכול לסגור חלון זה',
                        ERROR: 'שגיאה. נסה שוב מאוחר יותר.',
                        IMAGE_ERROR: 'התמונה לא נמצאה',
                        ELEMENT_NOT_FOUND: 'האלמנט לא נמצא',
                        AJAX_NOT_FOUND: 'שגיאת טעינה',
                        AJAX_FORBIDDEN: 'שגיאה. לא ניתן לטעון',
                        IFRAME_ERROR: 'שגיאת Iframe'
                    }
                },
                l10n: window.Fancybox ? (Fancybox.defaults.l10n || 'he') : 'he'
            });
        }
    }

    function buildCaption(item) {
        var parts = [];
        if (item.title) parts.push('<strong>' + escHtml(item.title) + '</strong>');
        if (item.text)  parts.push(item.text); // already stored HTML — pass through
        return parts.join('<br>');
    }

    function escHtml(s) {
        return (s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    function showError(container, msg) {
        container.innerHTML = '<span style="color:#c00;font-size:12px;">[Gallery error: ' + escHtml(msg) + ']</span>';
    }

    // Auto-run after DOM ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // Expose for programmatic re-render (e.g. after AJAX page load)
    window.DfyGallery = { render: renderGallery, init: init };
})();
