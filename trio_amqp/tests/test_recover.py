"""
    Amqp basic tests for recover methods
"""

import pytest

from . import testcase


class TestRecover(testcase.RabbitTestCase):

    @pytest.mark.trio
    async def test_basic_recover_async(self, channel):
        await channel.basic_recover_async(requeue=True)

    @pytest.mark.trio
    async def test_basic_recover_async_no_requeue(self, channel):
        await channel.basic_recover_async(requeue=False)

    @pytest.mark.trio
    async def test_basic_recover(self, channel):
        result = await channel.basic_recover(requeue=True)
        assert result
