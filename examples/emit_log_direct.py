#!/usr/bin/env python
"""
    Rabbitmq.com pub/sub example

    https://www.rabbitmq.com/tutorials/tutorial-four-python.html
"""

import anyio
import async_amqp

import sys


async def exchange_routing():
    try:
        async with async_amqp.connect_amqp() as protocol:

            channel = await protocol.channel()
            exchange_name = 'direct_logs'
            severity = sys.argv[1] if len(sys.argv) > 1 else 'info'
            message = ' '.join(sys.argv[2:]) or 'Hello World!'

            await channel.exchange(exchange_name, 'direct')

            await channel.publish(
                message, exchange_name=exchange_name, routing_key=severity
            )
            print(" [x] Sent %r" % (message,))

    except async_amqp.AmqpClosedConnection:
        print("closed connections")
        return

anyio.run(exchange_routing)
