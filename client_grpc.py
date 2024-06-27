import logging

import grpc
from add_service_pb2 import AddRequest, PingRequest, PlusPlusRequest
from add_service_pb2_grpc import AddServiceStub


def main():
    with grpc.insecure_channel("localhost:9001") as channel:
        logging.info("connected")
        client = AddServiceStub(channel)
        response = client.Add(AddRequest(num1=1, num2=2))
        logging.info(f"1 + 2 = {response.num}")
        response = client.PlusPlus(PlusPlusRequest(num=1))
        logging.info(f"1++ = {response.num}")
        client.Ping(PingRequest())


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
