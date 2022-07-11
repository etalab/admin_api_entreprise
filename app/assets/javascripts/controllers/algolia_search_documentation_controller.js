document.addEventListener("turbo:load", function () {
  window.Stimulus.register(
    "algolia-search-documentation",
    class extends window.StimulusController {
      static targets = ["searchBox"];
      static values = {
        index: String,
        attributesToHighlight: Array,
      };

      connect() {
        if (!this.hasIndexValue) {
          throw "algolia-search-algolia controller: index value is missing";
        }

        var search = this._createInstantSearchInstance();

        if (this.hasAttributesToHighlightValue) {
          this._configureHighlights(search);
        }
        this._configureSearchBox(search);

        search.start();
      }

      // private

      _createInstantSearchInstance() {
        let controller = this;

        var algoliaClient = window.algoliasearch(...controller._credentials());

        var searchClient = {
          ...algoliaClient,
          search(requests) {
            var search = algoliaClient.search(requests);

            search.then(function (event) {
              controller._updateResults(controller, event);
            });

            return search;
          },
        };

        return window.instantsearch({
          indexName: this.indexValue,
          searchClient,
          routing: true,
        });
      }

      _updateResults(controller, event) {
        var entriesInResult = [];
        var query = event.results[0].query;

        event.results[0].hits.forEach(function (hit) {
          entriesInResult = controller._handleHit(
            controller,
            hit,
            entriesInResult
          );
        });

        controller._hideEntriesNotInResult(entriesInResult);
      }

      _handleHit(controller, hit, entriesInResult) {
        var entry = document.querySelector(
          "[data-algolia-search-documentation-hit='" + hit.objectID + "']"
        );
        entriesInResult.push(entry);

        entry
          .querySelectorAll(
            "[data-algolia-search-documentation-hit-attribute]"
          )
          .forEach(function (element) {
            controller._handleHitHighlightingAttribute(
              controller,
              hit,
              element
            );
          });

        entry.classList.remove("fr-hidden");

        return entriesInResult;
      }

      _handleHitHighlightingAttribute(controller, hit, element) {
        var attribute = element.getAttribute(
          "data-algolia-search-documentation-hit-attribute"
        );

        if (
          controller.hasAttributesToHighlightValue &&
          controller.attributesToHighlightValue.includes(attribute)
        ) {
          element.innerHTML = instantsearch.highlight({
            attribute: attribute,
            hit: hit,
          });
        } else {
          element.innerHTML = hit[attribute];
        }
      }

      _hideEntriesNotInResult(entriesInResult) {
        var allEntries = document.querySelectorAll(
          "[data-algolia-search-documentation-hit]"
        );

        allEntries.forEach(function (entry) {
          if (!entriesInResult.includes(entry)) {
            entry.classList.add("fr-hidden");
          }
        });
      }

      _configureHighlights(search) {
        search.addWidget(
          instantsearch.widgets.configure({
            attributesToHighlight: this.attributesToHighlight,
            highlightPreTag: '<span class="search-highlight">',
            highlightPostTag: "</span>",
          })
        );
      }

      _configureSearchBox(search) {
        search.addWidget(
          instantsearch.widgets.configure({
            hitsPerPage: 1000,
          })
        );

        search.addWidget(
          instantsearch.widgets.searchBox({
            container: this.searchBoxTarget,
            autofocus: true,
            placeholder: this.searchBoxTarget
              .querySelector("input.fr-input")
              .getAttribute("placeholder"),
            showReset: false,
            showSubmit: true,
            cssClasses: {
              root: "fr-algolia-search",
              form: ["fr-search-bar", "fr-search-bar--lg"],
              input: "fr-input",
              submit: "fr-btn",
            },
            templates: {
              submit: this.searchBoxTarget.querySelector("button.fr-btn")
                .innerText,
            },
          })
        );

        this.searchBoxTarget.classList.remove("fr-hidden");
      }

      _credentials() {
        var nodeContainerWithAlgoliaCredentials = document.querySelector(
          "body"
        );

        return [
          nodeContainerWithAlgoliaCredentials.getAttribute(
            "data-algolia-application-id"
          ),
          nodeContainerWithAlgoliaCredentials.getAttribute(
            "data-algolia-search-key"
          ),
        ];
      }
    }
  );
});
