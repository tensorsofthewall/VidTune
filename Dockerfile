# Use micromamba as the base image
FROM python:3.9.19

# Set the working directory in the container
WORKDIR /src

# Copy Requirements file
COPY requirements.txt /src

# Install the required packages
RUN pip install -r requirements.txt

# Expose port 8003 for Streamlit
EXPOSE 8003

# Copy the current directory contents into the container at /src
COPY . /src

# Run id_cleaner.py as a background process and then start Streamlit
CMD ["sh", "-c", "python id_cleaner.py & streamlit run main.py --server.port 8003"]