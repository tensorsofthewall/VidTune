import requests
import argparse

# Parse command line arguments
parser = argparse.ArgumentParser(description="Music Generation Client")
parser.add_argument(
    "--server_url", type=str, default="http://localhost:8000", help="URL of the server"
)
parser.add_argument(
    "--prompts",
    nargs="+",
    type=str,
    default=["Lofi Music for Coding"],
    help="Prompts for music generation",
)
parser.add_argument(
    "--output_file", type=str, default="output.wav", help="Output file name"
)
parser.add_argument(
    "--duration", type=int, default=10, help="Duration of generated music in seconds"
)

args = parser.parse_args()

def generate_music(server_url, prompts, duration, output_file):
    url = f"{server_url}/generate_music"
    headers = {"Content-Type": "application/json"}
    data = {"prompts": prompts, "duration": duration}

    response = requests.post(url, json=data, headers=headers)

    if response.status_code == 200:
        with open(output_file, "wb") as f:
            f.write(response.content)
        print(f"Music saved to {output_file}")
    else:
        print(f"Failed to generate music: {response.status_code}, {response.text}")

if __name__ == "__main__":
    generate_music(args.server_url, args.prompts, args.duration, args.output_file)
