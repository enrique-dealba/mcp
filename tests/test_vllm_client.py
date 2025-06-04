import json
import sys
from types import SimpleNamespace
import pytest


class DummyOpenAI(SimpleNamespace):
    pass


# Provide a minimal stub for the openai package so that vllm_client can be imported
sys.modules["openai"] = SimpleNamespace(OpenAI=lambda *args, **kwargs: DummyOpenAI())

import vllm_client


def test_add():
    assert vllm_client.add(2, 3) == 5


def test_multiply():
    assert vllm_client.multiply(2, 3) == 6


def test_divide():
    assert vllm_client.divide(6, 3) == 2


def test_divide_by_zero():
    with pytest.raises(ValueError):
        vllm_client.divide(1, 0)


def test_math_tool_functions_mapping():
    assert vllm_client.MATH_TOOL_FUNCTIONS["add"](1, 2) == 3
    assert vllm_client.MATH_TOOL_FUNCTIONS["multiply"](2, 4) == 8
    assert vllm_client.MATH_TOOL_FUNCTIONS["divide"](8, 2) == 4


def test_chat_with_tools_executes_tool(monkeypatch):
    # Prepare dummy response with a tool call
    tool_call = SimpleNamespace(
        name="add",
        arguments=json.dumps({"a": 2, "b": 3})
    )
    message = SimpleNamespace(tool_calls=[SimpleNamespace(function=tool_call)])
    response = SimpleNamespace(choices=[SimpleNamespace(message=message)])

    def dummy_create(**kwargs):
        return response

    dummy_client = DummyOpenAI(
        chat=SimpleNamespace(completions=SimpleNamespace(create=dummy_create)),
        models=SimpleNamespace(list=lambda: SimpleNamespace(data=[SimpleNamespace(id="model")]))
    )

    monkeypatch.setattr(vllm_client, "OpenAI", lambda base_url, api_key: dummy_client)
    client = vllm_client.VLLMClient()

    result = client.chat_with_tools(
        message="add numbers",
        tools=vllm_client.MATH_TOOLS,
        tool_functions=vllm_client.MATH_TOOL_FUNCTIONS,
    )

    assert result["result"] == 5
    assert result["tool_call"].name == "add"
