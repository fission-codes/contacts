import * as webnative from "webnative"
import * as webnativeElm from "webnative-elm"
import copy from "copy-to-clipboard"

import { Elm } from "../Application/Main.elm"


// ELM


const app = Elm.Main.init({
  flags: {
    seeds: Array.from(
      crypto.getRandomValues(new Uint32Array(4))
    )
  }
})


app.ports.copyToClipboard.subscribe(({ notification, text }) => {
  copy(text)

  if (notification && "Notification" in window) {
    Notification.requestPermission().then(permission => {
      if (permission === "granted") new Notification(notification)
    })
  }
})


app.ports.signOut.subscribe(() => {
  webnative.leave()
})



// WEBNATIVE


webnative.setup.debug({ enabled: true })


webnativeElm.setup({ app, webnative })
