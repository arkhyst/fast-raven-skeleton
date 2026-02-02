<?php

use FastRaven\Components\Http\Request;
use FastRaven\Components\Http\Response;
use FastRaven\Types\SanitizeType;

return function(Request $request): Response {
    $question = $request->post("question", SanitizeType::SANITIZED);

    if($question === null) return Response::new(false, 400, "Missing question.");
    else if($question !== "What time is it?") return Response::new(false, 400, "Invalid question.");
    else return Response::new(true, 200, "Valid question.", [
        "answer" => date("H:i:s", time())
    ]);
};