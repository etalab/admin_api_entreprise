//= require rails-ujs
//= require_tree ./controllers
//= require_tree .

//= require chartkick
//= require Chart.bundle

function filterTable() {
  // Declare variables
  var input, filter, table, tr, td, i, txtValue;
  input = document.getElementById("search-input");
  search = input.value.toUpperCase();
  table = document.getElementsByClassName("filterable-table")[0];
  tr = table.getElementsByTagName("tr");

  // Loop through all table rows, and hide those who don't match the search query
  for (i = 1; i < tr.length; i++) {

    var filterable_elements = [].slice.call(tr[i].getElementsByClassName("filter"));

		filterable_text = filterable_elements.map(filterable => {
			if (filterable.hasAttribute('href')) {
				return filterable['href'];
			} else {
				return (filterable.innerText || filterable.textContent);
			}
		}).join(" ");

    if (filterable_text.toUpperCase().indexOf(search) > -1) {
      tr[i].style.display = "";
    } else {
      tr[i].style.display = "none";
    }
  }
};
