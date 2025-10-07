#!/usr/bin/env bash
# start-registry.sh - Start local npm registry for faster installs

echo "🚀 Starting local npm registry..."

# Kill any existing verdaccio processes
pkill -f verdaccio || true

# Start verdaccio in background
npx verdaccio --config verdaccio.yaml > verdaccio.log 2>&1 &
REGISTRY_PID=$!

echo "✅ Local registry started on http://localhost:4873"
echo "📋 Registry PID: $REGISTRY_PID"
echo "📝 Logs: verdaccio.log"

# Wait a moment for registry to start
sleep 3

# Configure npm to use local registry
npm config set registry http://localhost:4873

echo "✅ NPM configured to use local registry"
echo ""
echo "📦 To use local registry:"
echo "   npm install"
echo ""
echo "🌐 To use public registry again:"
echo "   npm config set registry https://registry.npmjs.org/"
echo ""
echo "🛑 To stop registry:"
echo "   kill $REGISTRY_PID"

# Keep script running to show logs
echo ""
echo "📋 Registry logs:"
tail -f verdaccio.log
