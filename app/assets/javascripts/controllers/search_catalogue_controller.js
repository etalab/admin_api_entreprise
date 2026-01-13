document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "search-catalogue",
    class extends window.StimulusController {
      static targets = ["input", "card", "noResults", "title", "description", "matchingKeywords", "matchingAttributeKeys"];

      connect() {
        const params = new URLSearchParams(window.location.search);
        const query = params.get("s");
        if (query) {
          this.inputTarget.value = query;
          this.filter();
        }
      }

      filter() {
        const rawQuery = this.inputTarget.value;
        const query = this._normalize(rawQuery);
        this._updateUrl(rawQuery);

        if (query.length < 3) {
          this.cardTargets.forEach((card, index) => {
            card.style.display = "";
            this._updateHighlight(index, "");
            this._updateMatchingKeywords(index, "", []);
            this._updateMatchingAttributeKeys(index, "", []);
          });
          if (this.hasNoResultsTarget) {
            this.noResultsTarget.style.display = "none";
          }
          return;
        }

        let visibleCount = 0;

        this.cardTargets.forEach((card, index) => {
          const searchableText = this._normalize(card.dataset.searchable);
          const keywords = JSON.parse(card.dataset.keywords || "[]");
          const attributeKeys = JSON.parse(card.dataset.attributeKeys || "[]");
          const matchingKeywords = this._findMatchingKeywords(query, keywords);
          const matchingAttributeKeys = this._findMatchingAttributeKeys(query, attributeKeys);

          const matchesText = searchableText.includes(query);
          const matchesKeywords = matchingKeywords.length > 0;
          const matchesAttributeKeys = matchingAttributeKeys.length > 0;
          const isVisible = matchesText || matchesKeywords || matchesAttributeKeys;

          card.style.display = isVisible ? "" : "none";
          if (isVisible) visibleCount++;

          this._updateHighlight(index, query);
          this._updateMatchingKeywords(index, query, matchingKeywords);
          this._updateMatchingAttributeKeys(index, query, matchingAttributeKeys);
        });

        if (this.hasNoResultsTarget) {
          this.noResultsTarget.style.display = visibleCount === 0 ? "" : "none";
        }
      }

      _normalize(text) {
        return text
          .toLowerCase()
          .normalize("NFD")
          .replace(/[\u0300-\u036f]/g, "");
      }

      _findMatchingKeywords(query, keywords) {
        if (!query || keywords.length === 0) return [];

        const queryWords = query.split(/\s+/).filter(w => w.length > 0);
        if (queryWords.length === 0) return [];

        const matchedKeywords = [];
        const unmatchedWords = [];

        for (const word of queryWords) {
          const matchingKeyword = keywords.find(keyword => {
            const normalizedKeyword = this._normalize(keyword);
            return normalizedKeyword.includes(word);
          });

          if (matchingKeyword) {
            if (!matchedKeywords.includes(matchingKeyword)) {
              matchedKeywords.push(matchingKeyword);
            }
          } else {
            unmatchedWords.push(word);
          }
        }

        if (unmatchedWords.length > 0) return [];

        return matchedKeywords;
      }

      _updateMatchingKeywords(cardIndex, query, matchingKeywords) {
        const element = this.matchingKeywordsTargets[cardIndex];
        if (!element) return;

        if (query === "" || matchingKeywords.length === 0) {
          element.style.display = "none";
          element.innerHTML = "";
          return;
        }

        const tags = matchingKeywords.map(keyword => {
          return '<li><p class="fr-tag fr-tag--sm">' + keyword + '</p></li>';
        }).join("");

        element.innerHTML = '<u>Mots clés correspondants</u> :<ul class="fr-tags-group fr-tags-group--sm fr-mt-1v fr-mb-0">' + tags + '</ul>';
        element.style.display = "";
      }

      _findMatchingAttributeKeys(query, attributeKeys) {
        if (!query || attributeKeys.length === 0) return [];

        const queryWords = query.split(/\s+/).filter(w => w.length > 0);
        if (queryWords.length === 0) return [];

        const matchedKeys = [];

        for (const attrKey of attributeKeys) {
          const normalizedKey = this._normalize(attrKey.key);
          const normalizedDisplay = this._normalize(attrKey.display);

          for (const word of queryWords) {
            if (normalizedKey.includes(word) || normalizedDisplay.includes(word)) {
              if (!matchedKeys.find(k => k.key === attrKey.key)) {
                matchedKeys.push(attrKey);
              }
              break;
            }
          }
        }

        return matchedKeys;
      }

      _updateMatchingAttributeKeys(cardIndex, query, matchingAttributeKeys) {
        const element = this.matchingAttributeKeysTargets[cardIndex];
        if (!element) return;

        if (query === "" || matchingAttributeKeys.length === 0) {
          element.style.display = "none";
          element.innerHTML = "";
          return;
        }

        const queryWords = query.split(/\s+/).filter(w => w.length > 0);
        const tags = matchingAttributeKeys.map(attrKey => {
          const highlightedDisplay = this._highlightWords(attrKey.display, queryWords);
          return '<li><p class="fr-tag fr-tag--sm">' + highlightedDisplay + '</p></li>';
        }).join("");

        element.innerHTML = '<u>Données correspondantes</u> :<ul style="list-style: none;" class="fr-pl-0">' + tags + '</ul>';
        element.style.display = "";
      }

      _updateHighlight(cardIndex, query) {
        const title = this.titleTargets[cardIndex];
        const description = this.descriptionTargets[cardIndex];

        if (query === "") {
          this._clearHighlight(title);
          this._clearHighlight(description);
        } else {
          this._highlightText(title, query);
          this._highlightText(description, query);
        }
      }

      _highlightText(element, query) {
        if (!element) return;

        if (!element.dataset.originalText) {
          element.dataset.originalText = element.textContent;
        }

        element.innerHTML = this._highlightString(element.dataset.originalText, query);
      }

      _highlightString(text, query) {
        let result = "";
        let i = 0;

        while (i < text.length) {
          let j = 0;

          while (
            j < query.length &&
            i + j < text.length &&
            this._normalize(text.charAt(i + j)) === query.charAt(j)
          ) {
            j++;
          }

          if (j === query.length && j > 0) {
            result += '<span class="search-highlight">' + text.substring(i, i + j) + "</span>";
            i += j;
          } else {
            result += text.charAt(i);
            i++;
          }
        }

        return result;
      }

      _highlightWords(text, words) {
        let result = "";
        let i = 0;

        while (i < text.length) {
          let matched = false;

          for (const word of words) {
            let j = 0;

            while (
              j < word.length &&
              i + j < text.length &&
              this._normalize(text.charAt(i + j)) === word.charAt(j)
            ) {
              j++;
            }

            if (j === word.length && j > 0) {
              result += '<span class="search-highlight">' + text.substring(i, i + j) + "</span>";
              i += j;
              matched = true;
              break;
            }
          }

          if (!matched) {
            result += text.charAt(i);
            i++;
          }
        }

        return result;
      }

      _clearHighlight(element) {
        if (!element || !element.dataset.originalText) return;
        element.textContent = element.dataset.originalText;
      }

      _updateUrl(query) {
        const url = new URL(window.location);
        if (query) {
          url.searchParams.set("s", query);
        } else {
          url.searchParams.delete("s");
        }
        history.replaceState(null, "", url);
      }
    }
  );
});
