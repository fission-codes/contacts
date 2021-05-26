import * as webnativeElm from "webnative-elm"
import { Elm } from "../Application/Main.elm"


const app = Elm.Main.init({})


webnativeElm.setup({ app })
