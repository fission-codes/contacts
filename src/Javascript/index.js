import * as webnative from "webnative"
import * as webnativeElm from "webnative-elm"
import copy from "copy-to-clipboard"

import { Elm } from "../Application/Main.elm"


// ELM


const app = Elm.Main.init({})


app.ports.copyToClipboard.subscribe(({ notification, text }) => {
  copy(text)

  if (notification && "Notification" in window) {
    Notification.requestPermission().then(permission => {
      if (permission === "granted") new Notification(notification)
    })
  }
})



// WEBNATIVE


webnative.setup.debug({ enabled: true })


webnativeElm.setup({ app, webnative })
