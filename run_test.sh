#!/bin/bash

echo "Script started."

# Run server
echo "Starting server..."
python server.py --duration 10 &
echo "Server started."

# Sleep
echo "Waiting for the server to startup..."
sleep 10

# Run client
echo "Starting client..."
python client.py --server_url http://localhost:8000 --prompts "Lofi Music for Coding" --output_file output.wav 
echo "Client finished." 


# Kill server
echo "Killing server..."
kill $(ps aux | grep 'server.py' | awk '{print $2}') 


# Done
sleep 5
echo "Script finished."

