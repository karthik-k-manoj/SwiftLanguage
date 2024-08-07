import UIKit

// Async/await

/*
 Before async/await aysnchronous code was written using completion handlers and delegates.
 Problems: 1) can lead to deeply nested continuations (closures) that are hard to follow.
 2) Swift's built in error handling and `defer` cannot be used
 3) easy to make mistake i.e. easy to forget to call completion handler in the error case
 4) looking at the function it's unclear how often completion handlers gets called
 */

/*
 async/await is a shorter and easier to understand, it's more precise by looking at the type we can
 say this method returns a type or throws an error and that it'll return only once
 */

func loadEpisode() async throws -> [String] {
    sleep(1)
    return ["ep1", "ep2"]
}

func loadPoster(for episoder: String) async throws -> String {
    sleep(1)
    return "PosterImage"
}

// Structured concurrency. We can read it like synchrous code but internally this is an asynchronous code
// i.e. on line 33 `loadEpisode` is called and `loadFirstPosterFromEpisode` suspended and the thread is freed up
// and execution continues. Only when at the completion of the method `loadFirstPosterFromEpisode` is resumed to
// move to `loadPoster`
func loadFirstPosterFromEpisode() async throws -> String {
    let session = URLSession.shared
    let episoderURL = URL(string: "xx")!
    let episodes = try await loadEpisode()
    let poster = try await loadPoster(for: episodes.first ?? "")
    return poster
}


Task {
    let image = try await loadFirstPosterFromEpisode()
    print("Image", image)
}

// Let's see how much complexitiy it would be to do this using completion handlers

func loadEpisode(completion: @escaping (Result<[String], Error>) -> Void) {
    sleep(1)
    completion(.success(["ep1", "ep2"]))
}

func loadPoster(for episode: String, completion: @escaping (Result<String, Error>) -> Void) {
    sleep(2)
    completion(.success("PosterImage"))
}

// Harder to follow, Arrow code, , more line of code
// not obvious if the completion hanlder is called more than once looking at the function signature
// can miss to call completion handler, no compiler time warning if we miss to call completion handler
func loadFirstPosterFromEpisode(completion: @escaping (Result<String, Error>) -> Void) {
    loadEpisode { result in
        switch result {
        case .success(let episodes):
            let firstEpisode = episodes[0]
            loadPoster(for: firstEpisode) { result in
                switch result {
                case .success(let posterImage):
                    completion(.success(posterImage))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

loadFirstPosterFromEpisode { result in
    switch result {
    case .success(let posterImage):
        print("Image", posterImage)
    case .failure(let error):
        print("error", error)
    }
}

// another advantage of async/await is we can use `defer` to perform any actions that should be done before exiting the scope

// How asynchronous functions execute

/*
 - function is divided into parts at `await` statement. Under the hood Swift rewrite every async function containing
 suspension points to continuations.
 
 - on await the method is suspended and loading of data is done in a separate job. Once the job is finished, method is resumed and continues exeucting the second part in a separate job.
 
 - Swift's concurrency model is called `cooperative multitasking`. In short, this means functions should never block the current thread, but voluntarily suspend instead. A function can only be suspended at a potential suspension point (marked with await)
 
 - When the function is suspended it does not mean the current thread is blocked. instead control is given back to scheduler and other jobs can run on the thread in the meantime. At a later point  the scheduler resumes the function by calling the continuation.
 
 - Suspended function isn't guaranteed to resume on it's original thread.
 */

// Interfacing with completion handler

/*
 You might have function that uses completion handler. You can turn those methods to async/await method using `withCheckedContinuation`
 You can wrap any function that takes a completion handler in an async function
 */

func loadEpisode(episodeId: Int, completion: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
        completion(.success("Load Episode One"))
    }
    
}

loadEpisode(episodeId: 1) { result in
    print("Result from completion handler", result)
}

// To turn this into async API, we write a new async function and wrap the invocation of the original function in a call to
// `withCheckedThrowingContinuation`. It will run the body immediately and then suspend until we call `cont.resume` inside the body


func loadEpisode(episodeId: Int) async throws -> String {
    try await withCheckedThrowingContinuation { cont in
        loadEpisode(episodeId: episodeId) {
            cont.resume(with: $0)
        }
    }
}

// This task is going to be suspended and `loadEpisode` will be called on different thread
Task {
    let result = try await loadEpisode(episodeId: 1)
    print("Result from async method", result)
}

print("TASK IS ALREADY RUNNING")

func asyncMethod() async {
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
        print("waited")
    }
}

Task {
    await asyncMethod()
}

print("Waiting")


// checkedContinuation or checkedThrowingContinuation`. The inclusion of "Checked" means that both of these functions perform runtime checks
// to ensure we call resume exactly once. Calling it more than once is a runtime error. If we discard the continuation before calling it, we also get a warning at runtime

// `withUnsafeContinuation` and `withUnsafeThrowingContinuation` are a little bit more efficient at runtime because they skip the safety checks of their checked counterparts. You need to make sure to call the continuation exactly once. Not calling the continuation causes the task to never resume and calling it more than once is undefined behavior. It's good practice to write your code with checked variant and make sure they work before switching to the unsafe variants.

/* with..Continuation functions are useful beyond interfacing with existing completion handler-based code. In essence, they allow you to
    manually suspend a task and resume it at a later point.
 */

/*
 
 */

extension String {
    init(id: Int) async throws {
        self = try await withCheckedThrowingContinuation { cont in
            loadEpisode(episodeId: id) { result in
                cont.resume(with: result)
            }
        }
    }
}

Task {
    let myString =  try await String(id: 1)
    print("My String is", myString)
}

/*
 async/await makes asynchornous code structured. We can make use of swift built in construct such as conditionals, loops, error handling
 defer all work like they do in synchronous code. However async/await on it's own does not introdude concurrency i.e. multiple task
 executing on simulatenously. For that we need a way to create new tasks
 */

/*
 TASK
 a task is the fundamental execution context in a swift concurrency model. Every async function is executing in a task(so are the synchronous function called by the asynchronous function)
 
 Task server roughly the same purpose threads do in traditional multithreaded code. Like thread task on it's own has no concurrency.
 It runs one function at a time. When running task encounters an await it can suspend it's execution, giving up the thread and yielding control to the scheduler in the Swift runtime. The scheduler can then run another task on the same thread. When it's time to resume
 the first task the task will pick up exactly where it left off possibily on a different thread)
 */

/*
 Child Tasks vs Unstructured Tasks
 
 When we call an async function with await the called function will run in the same task as the caller. Creating a new task always
 requires explicit action. We can create two kinds of tasks
 
 1) Child Task- These form the basis for structured concurrency. We create child task with one of strucuted concurrency construct
 async let or task groups. Child tasks are organized in a tree and have a scoped lifetimes.
 
 2) Unstructured Task - These are standalone task that form the root of a new independent task tree. We create it either using Task init
 or the factory method  `Task.detached`. The lifetime of an unstructured task is independent of the lifetime of the current task
 
 */

Task {
    Task {
        try await loadEpisode(episodeId: 1)
    }
}
