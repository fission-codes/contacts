import * as webnative from "webnative"
import * as webnativeElm from "webnative-elm"
import copy from "copy-to-clipboard"

import { Elm } from "../Application/Main.elm"


// ELM


const app = Elm.Main.init({})


app.ports.copyToClipboard.subscribe(text => {
  copy(text)

  if ("Notification" in window) Notification.requestPermission().then(permission => {
    if (permission === "granted") new Notification("Copied to clipboard")
  })
})



// WEBNATIVE


webnative.setup.debug({ enabled: true })


webnativeElm.setup({ app, webnative })
