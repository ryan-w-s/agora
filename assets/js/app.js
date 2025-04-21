// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
// import {Socket} from "phoenix"
// import {LiveSocket} from "phoenix_live_view"
// import topbar from "../vendor/topbar"

// Add these imports
import { marked } from "marked";
import DOMPurify from "dompurify";

// LiveSocket setup - REMOVED/COMMENTED
/*
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks // Hook config removed
})
*/

// Topbar setup - REMOVED/COMMENTED (as it was tied to LiveView page loading)
/*
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())
*/

// LiveSocket connection - REMOVED/COMMENTED
/*
liveSocket.connect()
*/

// Expose liveSocket - REMOVED/COMMENTED
/*
window.liveSocket = liveSocket
*/

// Plain JavaScript Markdown Rendering
document.addEventListener('DOMContentLoaded', () => {
  const markdownElements = document.querySelectorAll('[data-markdown-source]');
  markdownElements.forEach(el => {
    const rawMarkdown = el.dataset.markdownContent;
    if (rawMarkdown) {
      const dirtyHtml = marked.parse(rawMarkdown);
      const cleanHtml = DOMPurify.sanitize(dirtyHtml);
      el.innerHTML = cleanHtml;
    }
  });
});

