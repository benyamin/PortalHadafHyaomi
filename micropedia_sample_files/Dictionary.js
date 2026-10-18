/**
 * DictionaryV2.js - Client-side functionality for stateless dictionary
 * Compatible with jQuery 1.10.2 and older browsers
 */

// Global variables for page state (set by server)
var dictionaryId, currentTab, currentWordId, previousWordId, nextWordId;

$(document).ready(function () {
    // Initialize page state first
    initializePageState();

    // Wait a bit for any server-side scripts to execute
    setTimeout(function() {
        onload();
    }, 100);

    // Set page title based on dictionary and tab
    updatePageTitle();
});

function onload() {
    // Initialize autocomplete for search box
    setupAutocomplete();

    // Setup link to page functionality
    setupLinkToPage();

    // Set menu selection
    setMenu();
}

/**
 * Initialize page state from server-side hidden fields
 */
function initializePageState() {
    dictionaryId = parseInt($('#hdnDictionaryId').val()) || 1;
    currentTab = $('#hdnCurrentTab').val() || 'search';
    currentWordId = $('#hdnCurrentWordId').val() || '';
    previousWordId = $('#hdnPreviousWordId').val() || '';
    nextWordId = $('#hdnNextWordId').val() || '';

    // Set current word in search box if available
    var currentWord = $('#hdnCurrentWord').val();
    if (currentWord) {
        $('#txtbox_wordTranslation_searchKeyword').val(currentWord);
    }

    // Set full text query if available
    var fullTextQuery = $('#hdnFullTextQuery').val();
    if (fullTextQuery) {
        $('#txtbox_Pattern').val(fullTextQuery);
    }

    // Set extended search checkbox state
    var freeText = $('#hdnFreeText').val();
    if (freeText === 'true') {
        $('#chkExtendedSearch').prop('checked', true);
    }
}

/**
 * Setup fast autocomplete using in-memory cache with "more results" support
 */
function setupAutocomplete() {
    $('#txtbox_wordTranslation_searchKeyword')
        .each(function () {  // IE11 hack
            this.addEventListener('input',
                function (ev) {
                    if (typeof flagAutoCompleteInitDone === 'undefined') {
                        ev.stopImmediatePropagation();
                    }
                }, false);
        })
        .autocomplete({
            source: function(request, response) {
                $.ajax({
                    url: 'DictionaryAutocomplete.ashx',
                    data: {
                        term: request.term,
                        id: dictionaryId
                    },
                    success: function(data) {
                        response(data);
                    },
                    error: function() {
                        response([]);
                    }
                });
            },
            minLength: 1,
            position: { my: "right top", at: "right bottom" }
        })
        .on("autocompleteselect", function (event, ui) {
            autocompleteSelect(event, ui);
        })
        .on("autocompletefocus", function (event, ui) {
            // Don't update textbox on focus, only on select
            event.preventDefault();
        })
        .on("click", function () {
            $(this).select();
        })
        .on("keypress", function (e) {
            if (e.which === 13) { // Enter key
                e.preventDefault();
                performSearch();
            }
        });

    // Override the _renderItem function after autocomplete is initialized - minimal override
    setTimeout(function() {
        var $searchBox = $('#txtbox_wordTranslation_searchKeyword');
        var autocompleteWidget = $searchBox.data("ui-autocomplete");
        if (autocompleteWidget) {
            // Store the original _renderItem function
            var originalRenderItem = autocompleteWidget._renderItem;

            autocompleteWidget._renderItem = function(ul, item) {
                // Use the default jQuery UI rendering for all items
                var $li = originalRenderItem.call(this, ul, item);

                // Only add special styling for "more results" option
                if (item.isMoreResults) {
                    $li.addClass("more-results-item");
                    $li.find('div').css({
                        'font-style': 'italic',
                        'color': '#666',
                        'background-color': '#f8f8f8',
                        'border-top': '2px solid #ddd'
                    });
                }

                return $li;
            };
        }
    }, 100);
}

/**
 * Handle autocomplete selection
 */
function autocompleteSelect(event, ui) {
    event.preventDefault();

    // Handle "more results" option
    if (ui.item.isMoreResults) {
        loadMoreAutocompleteResults(ui.item.searchTerm);
        return false;
    }

    // Handle regular result selection
    if (ui.item.isResult) {
        var url = buildUrl({
            tab: currentTab,
            wordId: ui.item.value
        });
        window.location.href = url;
    }

    return false;
}

/**
 * Load more autocomplete results
 */
function loadMoreAutocompleteResults(searchTerm) {
    var $searchBox = $('#txtbox_wordTranslation_searchKeyword');

    // Show loading indicator
    $searchBox.addClass('ui-autocomplete-loading');

    $.ajax({
        url: 'DictionaryAutocomplete.ashx',
        data: {
            term: searchTerm,
            id: dictionaryId,
            loadAll: 'true'
        },
        success: function(data) {
            // Remove loading indicator
            $searchBox.removeClass('ui-autocomplete-loading');

            // Close current dropdown
            $searchBox.autocomplete('close');

            // Store original source
            var originalSource = $searchBox.autocomplete('option', 'source');

            // Create a temporary source function that returns all results
            var allResultsSource = function(request, response) {
                response(data);
            };

            // Temporarily update the source
            $searchBox.autocomplete('option', 'source', allResultsSource);

            // Trigger autocomplete to show all results
            setTimeout(function() {
                $searchBox.autocomplete('search', searchTerm);

                // Reset source to normal after showing results
                setTimeout(function() {
                    $searchBox.autocomplete('option', 'source', originalSource);
                }, 200);
            }, 100);
        },
        error: function() {
            // Remove loading indicator on error
            $searchBox.removeClass('ui-autocomplete-loading');
            alert('שגיאה בטעינת תוצאות נוספות');
        }
    });
}

/**
 * Setup link to page functionality
 */
function setupLinkToPage() {
    if (currentWordId) {
        $('#lnkbtn_linkToPage').show();
        var linkUrl = window.location.protocol + '//' + window.location.host +
                     buildUrl({ wordId: currentWordId, source: '1' });
        $('#txtbox_linkToPage').val(linkUrl);
    }
}

/**
 * Set menu based on dictionary ID
 */
function setMenu() {
    if (dictionaryId == 1) {
        var menuHeader = $('#oMenu1');
        menuHeader.attr('class', 'clsOpened');
        menuHeader.next().show();
        menuHeader = $('#oSubMenu292');
        menuHeader.attr('class', 'clsOpened');
        menuHeader.next().show();
        $('#oSubSubMenu294').addClass('clsSelected');
    }
    else if (dictionaryId == 2) {
        var menuHeader = $('#oMenu1');
        menuHeader.attr('class', 'clsOpened');
        menuHeader.next().show();
        menuHeader = $('#oSubMenu26');
        menuHeader.attr('class', 'clsOpened');
        menuHeader.next().show();
        $('#oSubSubMenu395').addClass('clsSelected');
    }
    else if (dictionaryId == 3) {
        var menuHeader = $('#oMenu1');
        menuHeader.attr('class', 'clsOpened');
        menuHeader.next().show();
        menuHeader = $('#oSubMenu26');
        menuHeader.attr('class', 'clsOpened');
        menuHeader.next().show();
        $('#oSubSubMenu411').addClass('clsSelected');
    }
}

/**
 * Navigation function for full text pagination dropdown
 */
function navigateToFullTextPage(page) {
    if (page && page > 0) {
        var urlParams = getUrlParams();
        var url = buildUrl({
            tab: 'fulltext',
            query: urlParams.query,
            page: parseInt(page),
            freetext: urlParams.freetext === 'true'
        });
        window.location.href = url;
    }
}

/**
 * Perform word search
 */
function performSearch() {
    var searchTerm = $('#txtbox_wordTranslation_searchKeyword').val().trim();

    if (!searchTerm) {
        alert('נא להזין מילה לחיפוש');
        return;
    }

    // Validate Hebrew input
    if (searchTerm.length > 50 || !isValidHebrewInput(searchTerm)) {
        alert('נא להזין מילה עד 50 תווים באותיות עבריות');
        return;
    }

    if (location.pathname.toLocaleLowerCase().startsWith('/acronyms') && searchTerm.length > 1) {

        searchTerm = searchTerm.replace(/''|״/g, '"');

        if (searchTerm.lastIndexOf("'") == searchTerm.length - 2) {
            searchTerm = searchTerm.slice(0, -2) + '"' + searchTerm.slice(-1);
        }
        if (searchTerm.indexOf('"') == -1 && /[א-ת]{2,}$/.test(searchTerm)) {
            searchTerm = searchTerm.slice(0, -1) + '"' + searchTerm.slice(-1);
        }
    }

    var url = buildUrl({
        tab: 'search',
        word: searchTerm
    });

    window.location.href = url;
}

/**
* Navigate to specific word - implemented for backward compatibility with existing links
*/
function navWord(word) {
    if (!word) {
        alert('נא להזין מילה לחיפוש');
        return;
    }

    var url = buildUrl({
        tab: 'search',
        word: word
    });
    window.location.href = url;
}

/**
 * Perform full text search
 */
function performFullTextSearch() {
    var query = $('#txtbox_Pattern').val().trim();

    if (!query) {
        alert('נא להזין ביטוי לחיפוש');
        return;
    }

    // Validate input length and content
    if (query.length > 50 || query.length < 2) {
        alert('נא להזין ביטוי בין 2 ל-50 תווים');
        return;
    }

    // Validate Hebrew input
    if (!isValidHebrewInput(query)) {
        alert('נא להזין ביטוי באותיות עבריות');
        return;
    }

    // Get extended search checkbox state
    var isExtendedSearch = $('#chkExtendedSearch').is(':checked');

    var url = buildUrl({
        tab: 'fulltext',
        query: query,
        page: 1,
        freetext: isExtendedSearch
    });

    window.location.href = url;
}

/**
 * Navigate to previous word
 */
function navigateToPrevious() {
    if (previousWordId) {
        var url = buildUrl({
            tab: currentTab,
            wordId: previousWordId
        });
        window.location.href = url;
    }
}

/**
 * Navigate to next word
 */
function navigateToNext() {
    if (nextWordId) {
        var url = buildUrl({
            tab: currentTab,
            wordId: nextWordId
        });
        window.location.href = url;
    }
}

/**
 * Navigate to specific tab
 */
function navigateToTab(tab) {
    var url = buildUrl({
        tab: tab
    });
    window.location.href = url;
}

/**
 * Navigate to full text tab (preserving only dictionary ID)
 * This function is registered globally to handle tab navigation
 */
function navigateToFulltext() {
    var url = buildUrl({
        tab: 'fulltext'
    });
    window.location.href = url;
}

// Make sure the function is available globally
window.navigateToFulltext = navigateToFulltext;

/**
 * Navigate to character in browse tab
 */
function navigateToChar(character) {
    var url = buildUrl({
        tab: 'browse',
        char: character
    });
    window.location.href = url;
}

/**
 * Toggle link panel visibility
 */
function toggleLinkPanel() {
    var panel = $('#pnl_linkToPage');
    var link = $('#lnkbtn_linkToPage');

    if (panel.is(':visible')) {
        panel.hide();
        link.text('קישור לערך זה');
    } else {
        panel.show();
        link.text('הסתר קישור');
        $('#txtbox_linkToPage').select();
    }
}

/**
 * Build URL with current state and new parameters
 */
function buildUrl(params) {
    var url = location.pathname;
    var queryParams = [];

    // Always include dictionary ID to maintain state consistency
    queryParams.push('id=' + (dictionaryId || 1));

    // Add tab if not default
    var tab = params.tab || currentTab || 'search';
    if (tab !== 'search') {
        queryParams.push('tab=' + tab);
    }

    // Add navigation parameters (mutually exclusive)
    if (params.wordId) {
        queryParams.push('wordId=' + params.wordId);
    } else if (params.word) {
        queryParams.push('word=' + encodeURIComponent(params.word));
    } else if (params.char) {
        queryParams.push('char=' + params.char);
    }

    // Add full text search parameters
    if (tab === 'fulltext') {
        if (params.query) {
            queryParams.push('query=' + encodeURIComponent(params.query));
        }
        if (params.page && params.page > 1) {
            queryParams.push('page=' + params.page);
        }
        if (params.freetext === true) {
            queryParams.push('freetext=true');
        }
    }

    // Add source if specified
    if (params.source) {
        queryParams.push('source=' + params.source);
    }

    return queryParams.length > 0 ? url + '?' + queryParams.join('&') : url;
}

/**
 * Get URL parameters as object
 */
function getUrlParams() {
    var params = {};
    var queryString = window.location.search.substring(1);

    if (queryString) {
        var pairs = queryString.split('&');
        for (var i = 0; i < pairs.length; i++) {
            var pair = pairs[i].split('=');
            if (pair.length === 2) {
                params[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1]);
            }
        }
    }

    return params;
}

/**
 * Validate Hebrew input
 */
function isValidHebrewInput(text) {
    // Allow Hebrew letters, numbers, and basic punctuation
    var hebrewPattern = /^[א-ת\u0590-\u05FF\u200f\u200e\s\d\-_.,()'"!״?;:]+$/;
    return hebrewPattern.test(text);
}

/**
 * Update page title based on current state
 */
function updatePageTitle() {
    var title = document.title;

    if (currentTab === 'browse') {
        title += ' - עיון';
    } else if (currentTab === 'fulltext') {
        title += ' - חיפוש חופשי';
    } else {
        title += ' - חיפוש';
    }

    document.title = title;
}

/**
 * Change tab - updated for stateless navigation
 */
function changeTab(tabNumber) {
    var tab = 'search';

    switch (tabNumber) {
        case 1:
            tab = 'search';
            break;
        case 2:
            tab = 'browse';
            break;
        case 3:
            tab = 'fulltext';
            break;
    }

    navigateToTab(tab);
}

/**
 * Alphabet navigation for browse tab
 */
function alphabet(charNum, char) {
    navigateToChar(char);
}

/**
 * Highlight selected alphabet character
 */
function alphabet_highlightSelected(charNum) {
    // Remove previous highlighting
    $('.alphabet td').css('backgroundColor', 'transparent');

    // Highlight selected character
    $('#char' + charNum).css('backgroundColor', '#b6a259');
}

/**
 * Initialize autocomplete flag for IE11 compatibility
 */
var flagAutoCompleteInitDone = true;