#!/usr/bin/env python
"""
    RabbitMQ.com pub/sub example

    https://www.rabbitmq.com/tutorials/tutorial-three-python.html

"""

import anyio
import async_amqp

import sys


async def exchange_routing():
    try:
        async with async_amqp.connect_amqp() as protocol:

            channel = await protocol.channel()
            exchange_name = 'logs'
            message = ' '.join(sys.argv[1:]) or "info: Hello World!"

            await channel.exchange_declare(
                exchange_name=exchange_name, type_name='fanout'
            )
            await channel.basic_publish(
                message, exchange_name=exchange_name, routing_key=''
            )
            print(" [x] Sent %r" % (message,))

    except async_amqp.AmqpClosedConnection:
        print("closed connections")
        return


anyio.run(exchange_routing)
