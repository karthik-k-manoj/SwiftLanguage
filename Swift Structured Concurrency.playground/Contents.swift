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
