document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "search-catalogue",
    class extends window.StimulusController {
      static targets = ["input", "card", "noResults", "title", "description"];

      connect() {
        const params = new URLSearchParams(window.location.search);
        const query = params.get("s");
        if (query) {
          this.inputTarget.value = query;
          this.filter();
        }
      }

      filter() {
        const query = this._normalize(this.inputTarget.value);
        this._updateUrl(this.inputTarget.value);
        let visibleCount = 0;

        this.cardTargets.forEach((card, index) => {
          const searchableText = this._normalize(card.dataset.searchable);
          const isVisible = query === "" || searchableText.includes(query);

          card.style.display = isVisible ? "" : "none";
          if (isVisible) visibleCount++;

          this._updateHighlight(index, query);
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

        const original = element.dataset.originalText;
        const normalizedOriginal = this._normalize(original);
        const normalizedQuery = query;

        let result = "";
        let i = 0;

        while (i < original.length) {
          const normalizedChar = this._normalize(original.charAt(i));
          let matchLength = 0;
          let j = 0;

          while (
            j < normalizedQuery.length &&
            i + j < original.length &&
            this._normalize(original.charAt(i + j)) === normalizedQuery.charAt(j)
          ) {
            j++;
          }

          if (j === normalizedQuery.length && j > 0) {
            result += '<span class="search-highlight">' + original.substring(i, i + j) + "</span>";
            i += j;
          } else {
            result += original.charAt(i);
            i++;
          }
        }

        element.innerHTML = result;
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
