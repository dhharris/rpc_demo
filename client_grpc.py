import logging
from io import BytesIO

import grpc
from PIL import Image
from add_service_pb2 import AdRequest, AddRequest, PingRequest, PlusPlusRequest
from add_service_pb2_grpc import AddServiceStub


def main():
    with grpc.insecure_channel("localhost:9001") as channel:
        logging.info("connected")
        client = AddServiceStub(channel)
        response = client.Add(AddRequest(num1=1, num2=2))
        logging.info(f"1 + 2 = {response.num}")
        response = client.PlusPlus(PlusPlusRequest(num=1))
        logging.info(f"1++ = {response.num}")
        response = client.Ad(AdRequest())
        image = Image.open(BytesIO(response.img))
        image.show()
        client.Ping(PingRequest())  # Say goodbye :-)


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
