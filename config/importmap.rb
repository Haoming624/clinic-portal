# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "undo_delete", to: "undo_delete.js"

# pin "chartkick", to: "https://cdn.jsdelivr.net/npm/chartkick@5.0.1/dist/chartkick.min.js"
# pin "chart.js", to: "https://cdn.jsdelivr.net/npm/chart.js@4.5.0/dist/chart.umd.min.js"
# pin "@kurkle/color", to: "https://cdn.jsdelivr.net/npm/@kurkle/color@0.3.4/dist/color.min.js"
