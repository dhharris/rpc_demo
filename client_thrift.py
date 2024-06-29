from add_service import AddService

import logging
from io import BytesIO
from PIL import Image
from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol


def main():
    transport = TSocket.TSocket("localhost", 9090)
    transport = TTransport.TBufferedTransport(transport)
    protocol = TBinaryProtocol.TBinaryProtocol(transport)
    client = AddService.Client(protocol)
    transport.open()
    logging.info("connected")
    s = client.add(1, 2)
    logging.info(f"1 + 2 = {s}")
    s = client.plus_plus(1)
    logging.info(f"1++ = {s}")
    resp = client.ad()
    image = Image.open(BytesIO(resp))
    image.show()
    client.ping()  # Say goodbye :-)
    transport.close()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
