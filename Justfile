gen := "src/Generated"


@default: dev-build
	just dev-server


# 🛠


@clean:
	rm -rf build
	mkdir -p build


@dev-build: clean translate-schemas


@install-deps:
	pnpm install

	mkdir -p src/Static/fonts/
	cp node_modules/fission-kit/fonts/**/*.woff2 src/Static/fonts/


@production-build: clean translate-schemas
	./node_modules/.bin/vite build ./src \
		--config vite.config.js \
		--outDir ../build

	mkdir -p build/new/
	cp build/index.html build/new/index.html



# Pieces
# ======

@css:
	echo "🎨  Generating Css"
	TAILWIND_MODE=build ./node_modules/.bin/tailwind build --output {{gen}}/application.css


@translate-schemas:
	echo "🔮  Translating schemas into Elm code"
	mkdir -p src/Generated
	./node_modules/.bin/quicktype -s schema -o src/Generated/ChainID.elm --module ChainID src/Schemas/Dawn/ChainID.json
	./node_modules/.bin/quicktype -s schema -o src/Generated/Contact.elm --module Contact src/Schemas/Dawn/Contact.json


@validate-elm:
	elm make src/Application/Main.elm --output=/dev/null



# Development
# ===========

@dev-server:
	./node_modules/.bin/vite ./src \
		--clearScreen false \
		--config vite.config.js \
		--port 8006



# Watch
# =====

@watch:
	echo "👀  Watching for changes"
	just watch-schemas


@watch-schemas:
	# watchexec -p -w src/Schemas -e json -- just translate-schemas
